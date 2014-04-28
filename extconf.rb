#                                          -*- ruby -*-
# extconf.rb
#
# Modified at: <1999/8/19 06:38:55 by ttate> 
#

require 'mkmf'
require 'rbconfig'

$CFLAGS = case RUBY_VERSION
          when /^1\.9/; '-DRUBY19'
          when /^2\./; '-DRUBY19'
          else; ''
          end

implementation = case CONFIG['host_os']
                 when /linux/i; 'shadow'
                 when /sunos|solaris/i; 'shadow'
                 when /freebsd|mirbsd|netbsd|openbsd/i; 'pwd'
                 when /darwin/i; 'pwd'
                 else; nil
                   "This library works on OS X, FreeBSD, MirBSD, NetBSD, OpenBSD, Solaris and Linux."
                 end

ok = true

case implementation
when 'shadow'
  #$LDFLAGS = "-lshadow"

  if( ! (ok &= have_library("shadow","getspent")) )
    $LDFLAGS = ""
    ok = have_func("getspent")
  end

  ok &= have_func("fgetspent")
  ok &= have_func("setspent")
  ok &= have_func("endspent")
  ok &= have_func("lckpwdf")
  ok &= have_func("ulckpwdf")

  if ok
    if !have_func("sgetspent")
      $CFLAGS += ' -DSOLARIS'
    end
  end
when 'pwd'
  ok &= have_func("endpwent")
  ok &= have_func("getpwent")
  ok &= have_func("getpwnam")
  ok &= have_func("getpwuid")
  ok &= have_func("setpassent")
  ok &= have_func("setpwent")

  have_header("uuid/uuid.h")
  have_header("uuid.h")
else
  ok = false
end

have_header( "ruby/io.h")

if ok

  create_makefile("shadow", implementation)
else
  raise "You are missing some of the required functions from either shadow.h on Linux/Solaris, or pwd.h on FreeBSD/MirBSD/NetBSD/OpenBSD/OS X."
end
