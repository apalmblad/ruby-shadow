#                                          -*- ruby -*-
# extconf.rb
#
# Modified at: <1999/8/19 06:38:55 by ttate> 
#

require 'mkmf'

$CFLAGS = RUBY_VERSION =~ /1\.9/ ? '-DRUBY19' : ''

#$LDFLAGS = "-lshadow"

if( ! (ok = have_library("shadow","getspent")) )
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
  create_makefile("shadow")
else
  osx_ok = have_func( "endpwent" )
  osx_ok &= have_func( "getpwent" )
  osx_ok &= have_func( "getpwnam" )
  osx_ok &= have_func( "getpwnam_r" )
  osx_ok &= have_func( "getpwuid" )
  osx_ok &= have_func( "setpassent" )
  osx_ok &= have_func( "setpwent" )
  if osx_ok
    raise "It looks like you're on OSX.  There is a branch that might help here: https://github.com/apalmblad/ruby-shadow/tree/osx"
  end
end
