require File.dirname(__FILE__) + '/../test_helper'

class RoleTest < Test::Unit::TestCase
  ROLE_COUNT = 5  
  fixtures :roles

  def test_role_count
    assert_equal 5, ROLE_COUNT
  end
  
  def test_illegal_system_flag_change
    role = Approver.find(:first)
    role.is_system_role = false 
    begin
      role.save!
      flunk("Should not have reached here.")
    rescue ActiveRecord::RecordInvalid => rns_ex
      assert_not_nil rns_ex
    rescue Exception => ex
      flunk("Should not have entered this handler. Exception: " + ex.to_s)
    end
  end
  
  def test_illegal_user_flag_change
    role = Bannerite.find(:first)
    role.is_system_role = true
    begin
      role.save!
      flunk("Should not have reached here.")
    rescue ActiveRecord::RecordInvalid => rns_ex
      assert_not_nil rns_ex
    rescue Exception => ex
      flunk("Should not have entered this handler. Exception: " + ex.to_s)
    end    
  end
  
  def test_legal_user_flag_change
    role = Bannerite.find(:first)
    role.is_system_role = false
    begin
      saved = role.save!
      assert saved
    rescue Exception => ex
      flunk("Should not have entered this handler. Exception: " + ex.to_s)
    end    
  end
  
  def test_new_approver
    p1 = Approver.new(:name => "Frankus", :is_system_role => true)
    assert_equal "Frankus", p1.name
    assert_equal "Approver", p1.class.to_s
    assert_equal true, p1.is_system_role

    # Wasn't saved yet, so shouldn't find it.    
    p2 = Role.find_by_name("Frankus")    
    assert_nil p2
    
    # Save it now.
    p1.save
    assert_equal "Frankus", p1.name
    assert_equal "Approver", p1.class.to_s
    assert_equal true, p1.is_system_role
    
    # Should find it now.
    p3 = Role.find_by_name("Frankus")
    assert_equal "Frankus", p3.name
    assert_equal "Approver", p3.class.to_s
  end

  def test_missing_role_name
    p1 = Coordinator.new
    
    # Try to save it now.
    begin
      p1.save!
      flunk("Should have failed before reaching here.")
    rescue ActiveRecord::RecordInvalid => error
      assert_not_nil error
    rescue Exception => ex
      flunk("Should not have entered this handler. Exception: " + ex.to_s)
    end
    
    assert_not_nil p1
  end
  
  def test_existing_roles
    system_roles = ['requestor', 'coordinator', 'approver', 'manager']
    for sr in system_roles
      role = Role.find_by_name(sr)
      assert_equal role.class.to_s, sr.capitalize
      assert role.is_system_role
    end
  end

  def test_banner_user_roles
    r = Role.find(1)
    assert_equal 'banner_user', r.name 
    assert !r.is_system_role
  end
  
  def test_nonexistant_role
    role = Role.find_by_id(0)
    assert_nil role
    
    role = Role.find_by_id(7)
    assert_nil role
  end  
  
end
