require File.dirname(__FILE__) + '/../test_helper'

class ActionTypeTest < Test::Unit::TestCase
  include ApplicationHelper
  
  def test_is_nil_or_empty
    assert Strings.is_nil_or_empty(nil)
    assert Strings.is_nil_or_empty('')
    assert Strings.is_nil_or_empty('  ')
    assert Strings.is_nil_or_empty("\t")
    assert Strings.is_nil_or_empty("  \t  ")
    assert Strings.is_nil_or_empty("\n")
    assert Strings.is_nil_or_empty("  \n  ")
    
    assert !Strings.is_nil_or_empty('a')
    assert !Strings.is_nil_or_empty(' f')
    assert !Strings.is_nil_or_empty('j ')
    assert !Strings.is_nil_or_empty("\t.")
  end
  
  def test_space_to_nbsp
    assert_equal '&nbsp;', Strings.space_to_nbsp(' ')
    assert_equal 'F&nbsp;D', Strings.space_to_nbsp('F D')
    assert_equal 'FD&nbsp;', Strings.space_to_nbsp('FD ')
  end
end