require 'test_helper'
require 'login_controller'

class LoginControllerTest < ActionController::IntegrationTest
  
  fixtures :users
  
  def setup
    self.host="test.host"
  end
  
  def test_login
    get 'bsar/login/lookup_user'
    expected_url ="/bsar/login/lookup_user?cookies_enabled=checked"
    assert_response :redirect
    assert_redirected_to expected_url
    
    get 'bsar/login/lookup_user'
    expected_url = ENV['CAS_BAS_URL'] + "/login?service="
    expected_url += ENV['BAS_URL_ENCODED'] + "%2Flogin%2Flookup_user"
    
    assert_response :redirect
    assert_redirected_to expected_url 
  end 
  
end        
