require File.dirname(__FILE__) + '/../test_helper'

class ActionTypeTest < Test::Unit::TestCase
  fixtures :action_types
  
  def test_count
    at_count = ActionType.find(:all).size
    assert at_count > 0
  end
  
  def test_accessors
    at = action_types(:approve)
    assert_equal 1, at.id
    assert_equal 'Approve', at.description
  end
  
end
