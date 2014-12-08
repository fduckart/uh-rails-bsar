require File.dirname(__FILE__) + '/../test_helper'

class UserTest < Test::Unit::TestCase
  fixtures :users
  fixtures :roles

  def test_add_user
    user_count = User.count
    
    Role.find_system_roles(:all).each do |role|
      user = User.new
      user.username = 'admin_' + role.id.to_s
      user.role = role
      user.save!      
    end
    
    system_count = Role.find(:all, :conditions => 'is_system_role = true').size
    assert User.count == user_count + system_count
  end

  def test_add_user_without_role
    user_count = User.count
    
    user = User.new
    user.username = "auwr"
    user.role = roles(:approver)
    
    begin 
      user.save!
      flunk("Should have not reached here.")
    rescue Exception => ex
      assert_not_nil ex       
    end 
    
    assert_equal User.count, user_count + 1
  end
  
  def test_delete_user
    user_count = User.count
    user = User.find(1)
    assert_equal "user_one", user.username
    user.destroy
    assert_equal user_count - 1, User.count
  end
  
  def test_user_role
    role = Bannerite.find(:first)
    assert_not_nil role
    user = users(:banner_user)
    assert_not_nil user
    
    assert_equal role, user.role
    assert_equal 1, user.role.id
    assert !user.is_system_user?
  end 
end
