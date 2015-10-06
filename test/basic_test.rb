require 'test/unit'
require 'rubygems'
require 'shadow'
class RubyShadowTest < Test::Unit::TestCase
  STRUCT_METHODS = %w( sp_namp sp_pwdp sp_lstchg sp_min sp_max sp_warn sp_inact sp_expire sp_loginclass )
  # --------------------------------------------------- test_smoke_test_getspent
  def test_smoke_test_getspent
    x = Shadow::Passwd.getspent
    check_struct( x )
  end
  # ----------------------------------------------------- test_getspnam_for_user
  def test_getspnam_for_user
    user = `whoami`.strip
    x = Shadow::Passwd.getspnam( user )
    check_struct( x )
  end
  # ---------------------------------------- test_getspnam_for_non_existent_user
  def test_getspnam_for_non_existent_user
    assert_nil( Shadow::Passwd.getspnam( 'somebadusername' ) )
  end
  # -------------------------------------------------------------- test_putspent
  def test_putspent
    omit_if( Shadow::IMPLEMENTATION != 'SHADOW' )
    result = StringIO.open( '', 'w' ) do |fh|
      Shadow::Passwd.add_password_entry( sample_entry, fh )
    end
    raise result.inspect
  end
  # --------------------------------------------------------------- check_struct
  def check_struct( s )
    STRUCT_METHODS.each do |m|
      s.send( m )
    end
  end
  # ----------------------------------------------------------------- test_entry
  def sample_entry( &block )
    e = Shadow::Passwd::Entry.new
    e.sp_namp = 'test_user'
    e.sp_pwdp = 'password'
    yield e if block_given?
    return e
  end
end

