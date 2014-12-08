require File.dirname(__FILE__) + '/../test_helper'

class BannerObjectTypeTest < Test::Unit::TestCase
  fixtures :banner_object_types
  
  def test_count
    at_count = BannerObjectType.find(:all).size
    assert at_count > 0
  end
  
  def test_accessors
    ot1 = banner_object_types(:form)
    assert_equal 1, ot1.id
    assert_equal 'Form', ot1.description
    
    ot2 = banner_object_types(:class)
    assert_equal 2, ot2.id
    assert_equal 'Class', ot2.description
  end
  
end
