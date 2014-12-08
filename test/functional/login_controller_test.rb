require 'test_helper'
require 'login_controller'

class LoginControllerTest < ActionController::TestCase

  TITLE = "Administer BSAR"
  fixtures :users
  fixtures :roles 
  fixtures :access_matrix
  
  def setup
    authenticator = LoginHelper::AuthenticatorTestProxy.new
    @controller = LoginController.new(authenticator)
    @controller.person_finder = DummyPersonFinder.new(authenticator)
    
    @request    = ActionController::TestRequest.new
    @request.cookies['_bsar_session_id'] = "fake cookie bypasses filter"
    @response   = ActionController::TestResponse.new
  end

  def test_lookup_user_without_user_1
    get :lookup_user
    expected_url = ENV['CAS_BAS_URL'] + "/login?service="
    expected_url += ENV['BAS_URL_ENCODED'] + "%2Flogin%2Flookup_user"    
    assert_redirected_to expected_url 
    assert_response :redirect
  end
  
  def test_lookup_user_without_user_2
    get :lookup_user
    expected_url = ENV['CAS_BAS_URL'] + "/login?service="
    expected_url += ENV['BAS_URL_ENCODED'] + "%2Flogin%2Flookup_user"
    assert_redirected_to expected_url 
    assert_equal "Please log in...", flash[:notice]
    assert_response :redirect
  end

  def test_list_users_without_user
    get :list_users    
    expected_url = ENV['CAS_BAS_URL'] + "/login?service="
    expected_url += ENV['BAS_URL_ENCODED'] + "%2Flogin%2Flist_users"
    assert_redirected_to expected_url 
    assert_response :redirect
  end

  def test_index_with_requestor_user
    assert true # need test here.
  end
  
  def test_list_users_with_user
    get :list_users, {}, {:cas_user => users(:administrator).username}
    assert_response :success
    assert_template 'list_users'
    assert_select 'title', {:text => TITLE}
  end
  
  def test_lookup_user_with_user
    get :lookup_user, {}, {:cas_user => users(:administrator).username}
    assert_response :success
    assert_template 'lookup_user'
    assert_select "title", { :text => TITLE }
  end
  
  def test_add_user
    user_count = User.count
    user = User.find_by_username('davis')
    assert_nil user
    
    # Have an admin call up the Add User page.
    get :add_user, {}, {:cas_user => users(:administrator).username}
    assert_response :success
    assert_template 'add_user'
    
    # Pick out a role.
    role = Role.find_system_roles(:first)
    assert_not_nil role 
    
    # Add a new user.
    post :add_user, :user => {:username => 'davis', :role_id => role.id}
    assert_redirected_to 'bsar/login/list_users'
    
    assert_equal user_count + 1, User.count
    user = User.find_by_username('davis')
    assert_not_nil user
    assert_equal role.name, user.role.name
  end

  def test_add_user_with_duplicate
    user_count = User.count
    username = User.find(:first).username
    
    # Have an admin call up the Add User page.
    get :add_user, {}, {:cas_user => users(:administrator).username}
    assert_response :success
    assert_template 'add_user'
    
    # Pick out a role.
    role = Role.find_system_roles(:first)
    assert_not_nil role 
    
    # Try to add a new user without a username.
    post :add_user, :user => {:username => username, :role_id => role.id}
    assert_redirected_to 'bsar/login/add_user'
    msg = "The UH Username '#{username}' already exists in this system."
    assert_equal msg, flash[:notice]
    assert_equal user_count, User.count    
  end
  
  def test_add_user_with_missing_username
    user_count = User.count
    username = ''
    
    # Have an admin call up the Add User page.
    get :add_user, {}, {:cas_user => users(:administrator).username}
    assert_response :success
    assert_template 'add_user'
    
    # Pick out a role.
    role = Role.find_system_roles(:first)
    assert_not_nil role 
    
    # Try to add a new user without a username.
    post :add_user, :user => {:username => username, :role_id => role.id}
    assert_redirected_to 'bsar/login/add_user'
    assert_equal "You must enter a UH Username.", flash[:notice]
    assert_equal user_count, User.count
  end
  
  def test_add_user_with_invalid_cas_user
    username = 'shitname'
    user_count = User.count
    user = User.find_by_username(username)
    assert_nil user
    
    # Have an admin call up the Add User page.
    get :add_user, {}, {:cas_user => users(:administrator).username}
    assert_response :success
    assert_template 'add_user'
    
    # Pick out a role.
    role = Role.find_system_roles(:first)
    assert_not_nil role 
    
    # Try to add a new user that should be invalid.
    post :add_user, :user => {:username => username, :role_id => role.id}
    assert_redirected_to 'bsar/login/add_user'
    assert_equal "'#{username}' is not a valid UH Username.", flash[:notice]
    assert_equal user_count, User.count
    user = User.find_by_username(username)
    assert_nil user
  end
  
  def test_user_homes    
    users = User.find(:all, :conditions => "id > 1")
    for u in users
      post :login, :username => u.username
      assert_response :redirect
      assert_redirected_to "bsar/login/#{u.role.home}"
      assert_select "body", "You are being redirected."
      assert_select "a", {:text => 'redirected', 
                          :href=>"home_#{u.role.home}"}
      
      get "#{u.role.home}"
      assert_template "login/#{u.role.home}"
    end
  end
  
  def test_requestor_list_users_request()
    user = users(:requestor)
    get :list_users, {}, {:cas_user => user.username}
    assert_response :redirect
  end
  
  def test_requestor_add_user_request()
    user = users(:requestor)
    get :add_user, {}, {:cas_user => user.username}
    assert_response :redirect
  end
  
  def test_requestor_lookup_user_request()
    user = users(:requestor)
    get :lookup_user, {}, {:cas_user => user.username}
    assert_response :success
  end

end
