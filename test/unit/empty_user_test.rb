require File.dirname(__FILE__) + '/../test_helper'

class EmptyUserTest < Test::Unit::TestCase
  def test_constructor
    uid = 'duckart'
    user = EmptyUser.new(uid)
    
    assert_not_nil user
    assert_not_nil user.uid
    assert_not_nil user.display_name
    assert_not_nil user.email
    assert_equal uid, user.uid
  end
  
  def test_constructor_with_nil
    uid = nil
    user = EmptyUser.new(uid)
    
    assert_not_nil user
    assert_not_nil user.uid
    assert_not_nil user.display_name
    assert_not_nil user.email
  end
  
end