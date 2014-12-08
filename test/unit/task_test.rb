require File.dirname(__FILE__) + '/../test_helper'

class TaskTest < Test::Unit::TestCase
  include ApplicationHelper
  
  fixtures :tasks
  
  def test_accessors()
    task = Task.new
    task.name = 'Testing'
    task.description = 'A Test'
    task.save!
    
    assert task.id > 0
    assert_equal 'Testing', task.name
    assert_equal 'A Test', task.description
  end
  
  def test_new_account_task_name()
    task = tasks(:new_account)
    assert_equal('New Account', task.name)
  end
  
  def test_helper_constants()
    new_account_task = tasks(:new_account)
    assert_equal(TaskType::NEW_ACCOUNT, new_account_task.id)
    new_account_task = Task.find(TaskType::NEW_ACCOUNT)
    assert_equal(TaskType::NEW_ACCOUNT, new_account_task.id)
    new_account_task = nil  
    
    remove_account_task = tasks(:terminate_account)
    assert_equal(TaskType::REMOVE_ACCOUNT, remove_account_task.id)
    remove_account_task = Task.find(TaskType::REMOVE_ACCOUNT)
    assert_equal(TaskType::REMOVE_ACCOUNT, remove_account_task.id)
    remove_account_task = nil
    
    reset_password_task = tasks(:reset_password)
    assert_equal(TaskType::RESET_PASSWORD, reset_password_task.id)
    reset_password_task = Task.find(TaskType::RESET_PASSWORD)
    assert_equal(TaskType::RESET_PASSWORD, reset_password_task.id)
    reset_password_task = nil
    
    modify_account_task = tasks(:modify_account)
    assert_equal(TaskType::MODIFY_ACCOUNT, modify_account_task.id)
    modify_account_task = Task.find(TaskType::MODIFY_ACCOUNT)
    assert_equal(TaskType::MODIFY_ACCOUNT, modify_account_task.id)
  end
end