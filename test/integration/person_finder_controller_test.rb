require File.dirname(__FILE__) + '/../test_helper'
require 'person_lookup_controller'

class PersonFinderControllerTest < Test::Unit::TestCase
  def setup
    @controller = PersonLookupController.new
    @request    = ActionController::TestRequest.new
    @request.cookies['_bsar_session_id'] = "fake cookie bypasses filter"
    @response   = ActionController::TestResponse.new
  end

  #
  # Straight controller tests.
  # 
  
  def test_lookup_by_userid
    assert_equal '17958670', @controller.lookup_by_userid('17958670').uhuuid
  end
  
  def test_failed_lookup_by_userid
    assert_nil @controller.lookup_by_userid('66666666')
  end
  
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
  
  def test_lookup_by_username
    assert_equal 'duckart', @controller.lookup_by_username('duckart').uid 
  end
  
  def test_lookup_by_fullname
    assert_not_nil @controller.lookup_by_username('duckart')
    assert_not_nil @controller.lookup_by_username('kellyt')
    assert_not_nil @controller.lookup_by_username('fkim')
    assert_not_nil @controller.lookup_by_username('FKim')
    assert_not_nil @controller.lookup_by_username('marquez3')
    assert_not_nil @controller.lookup_by_username('osuga')
    assert_not_nil @controller.lookup_by_username('shyannv')
    assert_not_nil @controller.lookup_by_username('jbtabuyo')
    assert_not_nil @controller.lookup_by_username('catolent')
  end
  
  def test_failed_lookup_by_username
    assert_nil @controller.lookup_by_username('no-way-no-how')
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
