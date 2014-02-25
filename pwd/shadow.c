/*
 * shadow.c
 *
 * Ruby extention module for using FreeBSD/OpenBSD/OS X pwd.h.
 *
 * Copyright (C) 1998-1999 by Takaaki.Tateishi(ttate@jaist.ac.jp)
 * License: Free for any use with your own risk!
 */
#include <sys/types.h>
#include <pwd.h>
#include <time.h>
#ifdef HAVE_UUID_UUID_H
#include <uuid/uuid.h>
#elif HAVE_UUID_H
#include <uuid.h>
#endif
#define PWTYPE  struct passwd

#include "ruby.h"
#ifdef HAVE_RUBY_IO_H
#include "ruby/io.h"
#else
#include "rubyio.h"
#endif

#ifdef RUBY19
#define file_ptr(x) (x)->stdio_file
#else
#define file_ptr(x) (x)->f
#endif

static VALUE rb_mShadow;
static VALUE rb_mPasswd;
static VALUE rb_sPasswdEntry;
static VALUE rb_mGroup;
static VALUE rb_sGroupEntry;
static VALUE rb_eFileLock;


static VALUE
rb_shadow_setspent(VALUE self)
{
  setpassent(1);
  return Qnil;
}


static VALUE
rb_shadow_endspent(VALUE self)
{
  endpwent();
  return Qnil;
}

static VALUE convert_pw_struct( struct passwd *entry )
{
  /* Hmm. Why custom pw_change instead of sp_lstchg? */
  return rb_struct_new(rb_sPasswdEntry,
         rb_tainted_str_new2(entry->pw_name), /* sp_namp */
         rb_tainted_str_new2(entry->pw_passwd), /* sp_pwdp, encryped password */
         Qnil, /* sp_lstchg, date when the password was last changed (in days since Jan 1, 1970) */
         Qnil, /* sp_min, days that password must stay same */
         Qnil, /* sp_max, days until password changes. */
         Qnil, /* sp_warn, days before expiration where user is warned */
         Qnil, /* sp_inact, days after password expiration that account becomes inactive */
         INT2FIX(difftime(entry->pw_change, 0) / (24*60*60)), /* pw_change */
         INT2FIX(difftime(entry->pw_expire, 0) / (24*60*60)), /* sp_expire */
         Qnil, /* sp_flag */
         NULL);
}

static VALUE
rb_shadow_getspent(VALUE self)
{
  PWTYPE *entry;
  VALUE result;
  entry = getpwent();

  if( entry == NULL )
    return Qnil;

  result = convert_pw_struct( entry );
  return result;
}

static VALUE
rb_shadow_getspnam(VALUE self, VALUE name)
{
  PWTYPE *entry;
  VALUE result;

  if( TYPE(name) != T_STRING )
    rb_raise(rb_eException,"argument must be a string.");
  entry = getpwnam(StringValuePtr(name));

  if( entry == NULL )
    return Qnil;

  result = convert_pw_struct( entry );
  return result;
}

void
Init_shadow()
{
  rb_sPasswdEntry = rb_struct_define("PasswdEntry",
                                     "sp_namp","sp_pwdp","sp_lstchg",
                                     "sp_min","sp_max","sp_warn",
                                     "sp_inact","pw_change",
                                     "sp_expire","sp_flag", NULL);
  rb_sGroupEntry = rb_struct_define("GroupEntry",
                                    "sg_name","sg_passwd",
                                    "sg_adm","sg_mem",NULL);

  rb_mShadow = rb_define_module("Shadow");
  rb_eFileLock = rb_define_class_under(rb_mShadow,"FileLock",rb_eException);
  rb_mPasswd = rb_define_module_under(rb_mShadow,"Passwd");
  rb_define_const(rb_mPasswd,"Entry",rb_sPasswdEntry);
  rb_mGroup = rb_define_module_under(rb_mShadow,"Group");
  rb_define_const(rb_mGroup,"Entry",rb_sGroupEntry);

  rb_define_module_function(rb_mPasswd,"setspent",rb_shadow_setspent,0);
  rb_define_module_function(rb_mPasswd,"endspent",rb_shadow_endspent,0);
  rb_define_module_function(rb_mPasswd,"getspent",rb_shadow_getspent,0);
  rb_define_module_function(rb_mPasswd,"getspnam",rb_shadow_getspnam,1);
}
