require File.dirname(__FILE__) + '/../test_helper'
require 'terminate_controller'
require 'dummy_person_finder'

class TerminateControllerPermissionTest < Test::Unit::TestCase
  include ApplicationHelper
  
  fixtures :reasons
  fixtures :tickets
  fixtures :tasks
  fixtures :users
  fixtures :access_matrix
  
  def setup
    authenticator = LoginHelper::AuthenticatorTestProxy.new() 
    @controller = TerminateController.new(authenticator)
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    @request.cookies['_bsar_session_id'] = "fake cookie bypasses filter" 
    
    @emails     = ActionMailer::Base.deliveries
    @emails.clear

    @controller.person_finder = DummyPersonFinder.new
    
    @no_permission_msg  = 'You do not have permissions to view that resource.'
    @enter_details_msg  = 'Request to Terminate Banner Access'
    @success_update_msg = 'Request was successfully updated.'
  end
  
  def test_new_ticket_bannerite()
    get :new, {}, {:cas_user => users(:banner_user).username}
    assert_response :redirect
    assert_redirected_to :controller => 'login', :action => 'index'
    assert_equal @no_permission_msg, flash[:notice]
  end

  def test_new_ticket_requestor()
    requestor = users(:requestor)  
    get :new, {}, {:cas_user => requestor.username}
    assert_response :success
    assert_template 'new'
    assert_select 'legend', @enter_details_msg
  end

  def test_new_ticket_coordinator()
    user = users(:coordinator)  
    get :new, {}, {:cas_user => user.username}
    assert_response :success
    assert_template 'new'
    assert_select 'legend', @enter_details_msg    
  end  
  
  def test_new_ticket_approver()
    user = users(:approver)  
    get :new, {}, {:cas_user => user.username}
    assert_response :success
    assert_template 'new'
    assert_select 'legend', @enter_details_msg        
  end

  def test_new_ticket_manager()
    user = users(:manager)  
    get :new, {}, {:cas_user => user.username}
    assert_response :success
    assert_template 'new'
    assert_select 'legend', @enter_details_msg    
  end

  def test_edit_ticket_bannerite()   
    # Create the ticket to be edited.
    user = users(:banner_user)
    ticket = create_new_ticket(user.username)    
    original_desc = ticket.description
    
    new_desc = 'I am a King Bee'
    assert_not_equal ticket.description, new_desc
    get :edit, {:id => ticket.id}, {:cas_user => user.username}
    post_edit_ticket(ticket, new_desc)
    assert_response :redirect
    assert_redirected_to :controller => 'login', :action => 'index'
    
    t = Ticket.find(ticket.id)
    assert_equal ticket.id, t.id
    assert_not_equal t.description, new_desc
    assert_equal t.description, original_desc
  end
       
  def test_edit_ticket_requestor()
    # Create the ticket to be edited.
    ticket_count = Ticket.count
    user = users(:requestor)
    ticket = create_new_ticket(user.username)
    assert_equal Ticket.count, ticket_count + 1
    
    new_desc = 'Honky Tonk Blues'
    assert_not_equal ticket.description, new_desc
    get :edit, {:id => ticket.id}, {:cas_user => user.username}
    assert_response :success 
     
    post_edit_ticket(ticket, new_desc)
    assert_response :redirect
    assert_redirected_to :controller => 'ticket', :action => 'open'
    
    t = Ticket.find(ticket.id)    
    assert_equal t.description, new_desc
  end
  
  def test_edit_ticket_coordinator()
    # Create the ticket to be edited.
    ticket_count = Ticket.count
    user = users(:coordinator)
    ticket = create_new_ticket(user.username, "Your phone's off the Hook")    
    assert_equal Ticket.count, ticket_count + 1
        
    new_desc = "But You're Not"
    assert_not_equal ticket.description, new_desc
    get :edit, {:id => ticket.id}, {:cas_user => user.username}
    assert_response :success
    
    post_edit_ticket(ticket, new_desc)
    assert_response :redirect
    assert_redirected_to :controller => 'ticket', :action => 'open'
    
    t = Ticket.find(ticket.id)
    assert_equal t.description, new_desc    
  end
   
  def test_edit_ticket_approver()
    # Create the ticket to be edited.
    ticket_count = Ticket.count
    user = users(:approver)
    ticket = create_new_ticket(user.username, 'Happiness Is')
    assert_equal Ticket.count, ticket_count + 1    
         
    new_desc = 'A Warm Gun'
    assert_not_equal ticket.description, new_desc
      
    get :edit, {:id => ticket.id}, {:cas_user => users(:duckart).username}
    assert_response :success
      
    post_edit_ticket(ticket, new_desc)
    assert_response :redirect
    assert_redirected_to :controller => 'ticket', :action => 'open'
    
    t = Ticket.find(ticket.id)
    assert_equal t.description, new_desc        
  end
   
  def test_edit_ticket_manager()
    # Create the ticket to be edited.
    ticket_count = Ticket.count
    user = users(:manager)
    ticket = create_new_ticket(user.username, 'Remove me!')
    assert_equal Ticket.count, ticket_count + 1    
         
    new_desc = 'How Many Times Do You Have To Fall?'
    assert_not_equal ticket.description, new_desc
      
    get :edit, {:id => ticket.id}, {:cas_user => users(:duckart).username}
    assert_response :success
      
    post_edit_ticket(ticket, new_desc)
    assert_response :redirect
    assert_redirected_to :controller => 'ticket', :action => 'open'
    t = Ticket.find(ticket.id)
    assert_equal t.description, new_desc        
  end
      
  def test_close_ticket_bannerite()
    # Create the ticket to be closed.
    ticket_count = Ticket.count
    user = users(:banner_user)
    ticket = create_new_ticket(user.username, 'Close me!')
    assert_equal Ticket.count, ticket_count + 1
    
    new_desc = 'Dirty Old Pan of Oil'
    assert_not_equal ticket.description, new_desc
    
    # Attempt to close the ticket; won't be able.
    get :edit, {:id => ticket.id}, {:cas_user => user.username}
    assert_response :redirect
    assert_redirected_to :controller => 'login', :action => 'index'

    post_close_ticket(ticket)
    assert_response :redirect
    assert_redirected_to :controller => 'login', :action => 'index'
    
    t = Ticket.find(ticket.id)
    assert_equal State::OPEN, t.state    
    assert_equal ticket.description, t.description
    assert_equal user.username, t.requestor_username
  end

  def test_close_ticket_requestor()
    # Create the ticket to be closed.
    ticket_count = Ticket.count
    user = users(:requestor)
    ticket = create_new_ticket(user.username, 'England Two')
    assert_equal Ticket.count, ticket_count + 1
    
    new_desc = 'Columbia Nil'
    assert_not_equal ticket.description, new_desc
    
    get :edit, {:id => ticket.id}, {:cas_user => user.username}
    assert_response :success
    t = Ticket.find(ticket.id)
    assert_equal State::OPEN, t.state
    assert_equal ticket.description, t.description
    assert_not_equal ticket.description, new_desc
    
    post_close_ticket(ticket, new_desc)
    assert_response :redirect
    assert_redirected_to :controller => 'ticket', :action => :open
  
    t = Ticket.find(ticket.id)
    assert_equal State::COMPLETE, t.state
    assert_equal new_desc, t.description
    assert_equal user.username, t.requestor_username
  end
  
  def test_close_ticket_coordinator()
    # Create the ticket to be closed.
    ticket_count = Ticket.count
    user = users(:coordinator)
    ticket = create_new_ticket(user.username, 'Up Go the Flaps')
    assert_equal Ticket.count, ticket_count + 1
    
    new_desc = 'Down Go the Wheels'
    assert_not_equal ticket.description, new_desc
    
    get :edit, {:id => ticket.id}, {:cas_user => user.username}
    assert_response :success
    t = Ticket.find(ticket.id)
    assert_equal State::OPEN, t.state
    assert_equal ticket.description, t.description
    assert_not_equal ticket.description, new_desc
    
    post_close_ticket(ticket, new_desc)
    assert_response :redirect
    assert_redirected_to :controller => 'ticket', :action => :open
  
    t = Ticket.find(ticket.id)
    assert_equal State::COMPLETE, t.state
    assert_equal new_desc, t.description
    assert_equal user.username, t.requestor_username
  end
  
  def test_close_ticket_approver()
    # Create the ticket to be closed.
    ticket_count = Ticket.count
    user = users(:approver)
    ticket = create_new_ticket(user.username, 'Gave me back Smile')
    assert_equal Ticket.count, ticket_count + 1
    
    new_desc = 'But he kept my camera to sell'
    assert_not_equal ticket.description, new_desc
    
    get :edit, {:id => ticket.id}, {:cas_user => user.username}
    assert_response :success
    t = Ticket.find(ticket.id)
    assert_equal State::OPEN, t.state
    assert_equal ticket.description, t.description
    assert_not_equal ticket.description, new_desc
    
    post_close_ticket(ticket, new_desc)
    assert_response :redirect
    assert_redirected_to :controller => 'terminate', :action => :open
  
    t = Ticket.find(ticket.id)
    assert_equal State::COMPLETE, t.state
    assert_equal new_desc, t.description
    assert_equal user.username, t.requestor_username
  end
  
  def test_close_ticket_approver()
    # Create the ticket to be closed.
    ticket_count = Ticket.count
    user = users(:manager)
    ticket = create_new_ticket(user.username, 'Will you take me as I am?')
    assert_equal Ticket.count, ticket_count + 1
    
    new_desc = 'California'
    assert_not_equal ticket.description, new_desc
    
    get :edit, {:id => ticket.id}, {:cas_user => user.username}
    assert_response :success
    t = Ticket.find(ticket.id)
    assert_equal State::OPEN, t.state
    assert_equal ticket.description, t.description
    assert_not_equal ticket.description, new_desc
    
    post_close_ticket(ticket, new_desc)
    assert_response :redirect
    assert_redirected_to :controller => 'ticket', :action => :open
  
    t = Ticket.find(ticket.id)
    assert_equal State::COMPLETE, t.state
    assert_equal new_desc, t.description
    assert_equal user.username, t.requestor_username
  end
  
=begin  
  def test_open_bannerite()
    get :open, {}, {:cas_user => users(:banner_user).username}
    assert_response :redirect
    assert_redirected_to :controller => 'login', :action => 'index'
    assert_equal @no_permission_msg, flash[:notice]    
  end
    
  def test_open_requestor()
    get :open, {}, {:cas_user => users(:requestor).username}
    assert_response :success
    assert_template 'open'
  end

  def test_open_coordinator()
    get :open, {}, {:cas_user => users(:coordinator).username}
    assert_response :success    
    assert_template 'open'
  end  

  def test_open_approver()
    get :open, {}, {:cas_user => users(:approver).username}
    assert_response :success    
    assert_template 'open'          
  end
  
  def test_open_manager()
    get :open, {}, {:cas_user => users(:manager).username}
    assert_response :success    
    assert_template 'open'      
  end  
=end
  def test_search_bannerite()
    get :search, {}, {:cas_user => users(:banner_user).username}
    assert_response :redirect
    assert_redirected_to :controller => 'login', :action => 'index'
    assert_equal @no_permission_msg, flash[:notice]    
  end
    
  def test_search_requestor()
    get :search, {}, {:cas_user => users(:requestor).username}
    assert_response :success
    assert_template 'search'
  end

  def test_search_coordinator()
    get :search, {}, {:cas_user => users(:coordinator).username}
    assert_response :success    
    assert_template 'search'
  end  

  def test_search_approver()
    get :search, {}, {:cas_user => users(:approver).username}
    assert_response :success    
    assert_template 'search'          
  end
  
  def test_search_manager()
    get :search, {}, {:cas_user => users(:manager).username}
    assert_response :success    
    assert_template 'search'      
  end    
    
  def test_index_bannerite()
    get :index, {}, {:cas_user => users(:banner_user).username}
    assert_response :redirect
    assert_redirected_to :controller => 'login', :action => 'index'
    assert_equal @no_permission_msg, flash[:notice]    
  end

  def test_index_requestor()
    get :index, {}, {:cas_user => users(:requestor).username}
    assert_response :redirect
    assert_redirected_to :controller => 'login', :action => 'index'
    assert_equal @no_permission_msg, flash[:notice]    
  end
  
  def test_index_coordinator()
    get :index, {}, {:cas_user => users(:coordinator).username}
    assert_response :redirect
    assert_redirected_to :controller => 'login', :action => 'index'
    assert_equal @no_permission_msg, flash[:notice]    
  end  

  def test_index_approver()
    get :index, {}, {:cas_user => users(:approver).username}
    assert_response :redirect
    assert_redirected_to :controller => 'login', :action => 'index'
    assert_equal @no_permission_msg, flash[:notice]    
  end
  
  def test_index_manager()
    get :index, {}, {:cas_user => users(:manager).username}
    assert_response :redirect
    assert_redirected_to :controller => 'login', :action => 'index'
    assert_equal @no_permission_msg, flash[:notice]    
  end  

  def test_new_no_auth()
    get :new
    expected_url = ENV['CAS_BAS_URL'] + "/login?service="
    expected_url += ENV['BAS_URL_ENCODED'] + "%2Fterminate%2Fnew"    
    assert_redirected_to expected_url 
    assert_response :redirect
  end  
  
  def test_edit_no_auth()
    get :edit
    expected_url = ENV['CAS_BAS_URL'] + "/login?service="
    expected_url += ENV['BAS_URL_ENCODED'] + "%2Fterminate%2Fedit"    
    assert_redirected_to expected_url 
    assert_response :redirect
  end
  
#  def test_open_no_auth()
#    get :open
#    expected_url = ENV['CAS_BAS_URL'] + "/login?service="
#    expected_url += "http%3A%2F%2Ftest.host%2Fticket%2Fopen"    
#    assert_redirected_to expected_url 
#    assert_response :redirect
#  end   
  
  def test_close_no_auth()
    get :close
    expected_url = ENV['CAS_BAS_URL'] + "/login?service="
    expected_url += ENV['BAS_URL_ENCODED'] + "%2Fterminate%2Fclose"    
    assert_redirected_to expected_url 
    assert_response :redirect
  end
  
  def test_search_no_auth()
    get :search
    expected_url = ENV['CAS_BAS_URL'] + "/login?service="
    expected_url += ENV['BAS_URL_ENCODED'] + "%2Fterminate%2Fsearch"    
    assert_redirected_to expected_url 
    assert_response :redirect
  end
  
  #-----------------------------------------------------------------------------
  private
  
  def post_new_ticket(username = 'cahana')
    post  :new, 
          :new_ticket => { 
                          :state => State::OPEN,
                          :username => username,
                          :description => 'Testing 1 2 3',
                          :date => Time.now,
                          :reason => reasons(:separated).id
                          }
  end
  
  def post_edit_ticket(ticket, description)
    post  :edit,   
          :edit_ticket => { 
                          :username => ticket.username,
                          :description => description}, 
          :id => ticket.id,
          :save => 'Save'
  end
  
  def post_close_ticket(ticket, description = Time.now.to_s)
    post  :edit,   
          :edit_ticket => { 
                          :username => ticket.username,
                          :description => description
                          }, 
          :id => ticket.id,
          :commit => 'Close'
  end
  
  def create_new_ticket(requestor_username, description = nil)
    t = Ticket.new
    t.requestor_username = requestor_username
    t.username = 'cahana'
    t.state = State::OPEN
    t.description = description
    t.date = Time.now
    t.reason = 2
    t.task_id = 2
    t.save!
    
    return t    
  end
  
end
