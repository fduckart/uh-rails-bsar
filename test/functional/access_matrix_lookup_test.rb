require File.dirname(__FILE__) + '/../test_helper'
require 'controller_actions'

class AccessMatrixLookupTest < Test::Unit::TestCase
  
  include ApplicationHelper

  fixtures :users
  fixtures :roles
  fixtures :access_matrix
  
  def setup()
    authenticator = LoginHelper::AuthenticatorTestProxy.new()
    @controller = LoginController.new(authenticator)
    
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end
  
  def test_singleton_declaration()
    finder0 = AccessMatrixLookup.instance()
    finder1 = AccessMatrixLookup.instance()
    assert_equal finder0.object_id, finder1.object_id
    assert_equal finder0, finder1
  end
  
  def test_coordinator_access()
    user = users(:coordinator)
    actions = ControllerActions::COORDINATOR_LOGIN
    assert(actions.size > 0)
    for a in actions
      @controller.action_name = a
      aml = AccessMatrixLookup.find(user, @controller)
      assert aml
    end
  end
  
  def test_requestor_access()
    requestor = users(:requestor)
    actions = ControllerActions::REQUESTOR_LOGIN
    assert(actions.size > 0)
    for a in actions
      @controller.action_name = a
      aml = AccessMatrixLookup.find(requestor, @controller)
      assert aml
    end
  end
  
  def test_manager_access()
    manager = users(:manager)
    actions = ControllerActions::MANAGER_LOGIN
    assert(actions.size > 0)
    for a in actions
      @controller.action_name = a
      assert AccessMatrixLookup.find(manager, @controller)
    end    
  end
end