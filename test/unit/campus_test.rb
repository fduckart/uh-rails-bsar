require File.dirname(__FILE__) + '/../test_helper'

class CampusTest < Test::Unit::TestCase
  def test_accessors
    c = Campus.new
    c.code = 'MAN'
    c.description = 'Manoa'
    
    assert_equal 'Manoa', c.description
    assert_equal 'MAN', c.code 
  end
  
  def test_duplicate_check
    campus_count = Campus.count
    
    c1 = Campus.new
    c1.code = 'MAN'
    c1.description = 'My Manoa 1'
    c1.save!
    
    c2 = Campus.new
    c2.code = 'MAN'
    c2.description = 'My Manoa 2'
    begin
      c2.save!
      flunk("Should have failed before reaching here; c2: " + c2.to_s)
    rescue Exception => ex
      assert_not_nil ex
    end
    
    c3 = Campus.new
    c3.code = 'HON'
    c3.description = 'Honolulu'
    c3.save!
    
    assert_equal campus_count + 2, Campus.count
  end
  
end
