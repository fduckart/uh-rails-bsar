require File.dirname(__FILE__) + '/../test_helper'
require 'person_lookup_controller'

class PersonFinderControllerTest < Test::Unit::TestCase
  def setup
    authenticator = LoginHelper::AuthenticatorTestProxy.new
    @controller = PersonLookupController.new(authenticator) 
    @request    = ActionController::TestRequest.new
    @request.cookies['_bsar_session_id'] = "fake cookie bypasses filter"
    @response   = ActionController::TestResponse.new
  end
  
  #
  # Straight controller tests that don't hit the actual LDAP server.
  # Puts tests that hit LDAP server in the intergration directory.
  # 
  
  def test_wildcard_lookup_by_userid
    # Wild cards not allowed.
    assert_nil @controller.lookup_by_username('1795867*')
    assert_nil @controller.lookup_by_username('1795867?')
    assert_nil @controller.lookup_by_username(' ')
  end
  
  def test_empty_lookup_by_userid
    # Empty string not allowed.
    assert_nil @controller.lookup_by_username("")
    assert_nil @controller.lookup_by_username('')
  end
  
  def test_wildcard_lookup_by_username
    # Wild cards not allowed.
    assert_nil @controller.lookup_by_username('duckart*')
    assert_nil @controller.lookup_by_username('duckart?')
  end
  
  #
  # Tests against pages.
  # 
  
  def test_lookup_user_without_user
    @controller = PersonLookupController.new 
    @request    = ActionController::TestRequest.new
    @request.cookies['_bsar_session_id'] = "fake cookie bypasses filter"
    @response   = ActionController::TestResponse.new
    get :lookup_user
    expected_url = ENV['CAS_BAS_URL'] + "/login?service="
    expected_url += ENV['BAS_URL_ENCODED'] + "%2Fperson_lookup%2Flookup_user"
    assert_redirected_to expected_url 
    assert_response :redirect
  end
  
end
