require File.dirname(__FILE__) + '/../test_helper'

class AccessMatrixTest < Test::Unit::TestCase
  include ControllerActions
  
  fixtures :access_matrix
  fixtures :roles
  
  def test_count()
    at_count = AccessMatrix.find(:all).size
    assert at_count > 0
  end
  
  def test_fixture()
    am = access_matrix(:id_1)
    assert_equal 1, am.id
  end
  
  def test_manager_access()
    # Managers have access to all of the terminate 
    # controller actions under the current design.
    manager = roles(:manager)
    conditions = "role_id = #{manager.id} AND controller = 'terminate'"
    accesses = AccessMatrix.find(:all, :conditions => conditions)
    
    assert accesses.size > 0
    for a in accesses
      assert a.allowed
    end
    
    # Managers have access to all of the login
    # controller actions under the current design.
    conditions = "role_id = #{manager.id} AND controller = 'terminate'"    
    accesses = AccessMatrix.find(:all, :conditions => conditions)
    assert accesses.size > 0
    for a in accesses
      assert a.allowed
    end
    
    # Everything else for managers if off right now.
    conditions = "role_id = #{manager.id} AND " 
    conditions += "controller NOT IN ('terminate', 'login', 'ticket')"
    accesses = AccessMatrix.find(:all, :conditions => conditions)
    assert_equal 0, accesses.size
  end

  def test_requestor_access()
    # Requestors have access to only some of the  
    # controller actions under the current design.
    requestor = roles(:requestor)
    conditions = "role_id = #{requestor.id} AND " + 
                 "controller = 'login' AND method = 'list_users'"
    accesses0 = AccessMatrix.find(:all, :conditions => conditions)
    assert(accesses0.size == 0)
    
    # But there are a lot of actions available for requestors.
    total = ControllerActions::REQUESTOR_LOGIN.length
    total += ControllerActions::REQUESTOR_TERMINATE.length
    total += ControllerActions::REQUESTOR_TICKET.length
    assert(total > 0)
    
    conditions = "role_id = #{requestor.id}"
    accesses1 = AccessMatrix.find(:all, :conditions => conditions)
    assert(accesses1.length > 0)
    assert(accesses1.length == total)
    for a in accesses1
      assert a.allowed
    end
  end
  
  def test_requestor_equals_coordinator()
    assert_equal REQUESTOR_TICKET, COORDINATOR_TICKET   
  end
end
