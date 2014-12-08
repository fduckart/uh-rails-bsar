require File.dirname(__FILE__) + '/../test_helper'
require 'ticket_controller'
require 'dummy_person_finder'

class TicketControllerPermissionTest < Test::Unit::TestCase
  include ApplicationHelper
  
  fixtures :action_types
  fixtures :campuses
  fixtures :users
  fixtures :tickets
  fixtures :reasons
  fixtures :tasks
   
  def setup
    authenticator = LoginHelper::AuthenticatorTestProxy.new() 
    @controller = TicketController.new(authenticator)
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    @request.cookies['_bsar_session_id'] = "fake cookie bypasses filter"
    
    @emails     = ActionMailer::Base.deliveries
    @emails.clear  

    @no_permission_msg  = 'You do not have permissions to view that resource.'
    @enter_details_msg  = 'Enter Banner Account Request Details'
    @success_update_msg = 'Request was successfully updated.'
  end
  
  # Tests the functions in the controller agains the access matrix.
  # access has a method listed for add - it needs to be removed - there is 
  # no such function in the controller. 
  
  #----------tests--------------------
  
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
    assert_not_nil assigns(:campuses)
    assert_not_nil assigns(:current_user)
    assert_template 'new'
    assert_select 'legend', @enter_details_msg
  end

  def test_new_ticket_coordinator()
    user = users(:coordinator)  
    get :new, {}, {:cas_user => user.username}
    assert_response :success
    assert_not_nil assigns(:campuses)
    assert_not_nil assigns(:current_user)
    assert_template 'new'
    assert_select 'legend', @enter_details_msg    
  end  
  
  def test_new_ticket_approver()
    user = users(:approver)  
    get :new, {}, {:cas_user => user.username}
    assert_response :success
    assert_not_nil assigns(:campuses)
    assert_not_nil assigns(:current_user)
    assert_template 'new'
    assert_select 'legend', @enter_details_msg        
  end

  def test_new_ticket_manager()
    user = users(:manager)  
    get :new, {}, {:cas_user => user.username}
    assert_response :success
    assert_not_nil assigns(:campuses)
    assert_not_nil assigns(:current_user)
    assert_template 'new'
    assert_select 'legend', @enter_details_msg    
  end
      
  def test_edit_ticket_bannerite()   
    # Create the ticket to be edited.
    user = users(:banner_user)
    ticket = create_new_ticket(user.username)    
    original_desc = ticket.description
    
    # Role 1 - banner_user.  
    new_desc = 'I am a King Bee'
    assert_not_equal ticket.description, new_desc
    get :edit, {}, {:cas_user => user.username}
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
    user = users(:requestor)
    ticket = create_new_ticket(user.username)    
        
    # Role 2 - requestor.
    new_desc = 'Honky Tonk Blues'
    assert_not_equal ticket.description, new_desc
    get :edit, {}, {:cas_user => user.username}
    assert_response :redirect 
    post_edit_ticket(ticket, new_desc)
    assert_response :redirect
    assert_redirected_to :controller => 'ticket', :action => 'open'
    t = Ticket.find(ticket.id)
    assert_equal t.description, new_desc
  end
  
  def test_edit_ticket_coordinator()
    # Create the ticket to be edited.
    user = users(:requestor)
    ticket = create_new_ticket(user.username)    
        
    # Role 2 - requestor.
    new_desc = 'Honky Tonk Blues'
    assert_not_equal ticket.description, new_desc
    get :edit, {}, {:cas_user => user.username}
    assert_response :redirect 
    post_edit_ticket(ticket, new_desc)
    assert_response :redirect
    assert_redirected_to :controller => 'ticket', :action => 'open'
    t = Ticket.find(ticket.id)
    assert_equal t.description, new_desc    
  end
  
  def test_edit_ticket_approver()
    # Create the ticket to be edited.
    user = users(:approver)
    ticket = create_new_ticket(user.username)    
        
    # Role -- approver.
    new_desc = 'I\'m Looking Up for the Next Thing'
    get :edit, {}, {:cas_user => user.username}
    assert_response :redirect 
    post_edit_ticket(ticket, new_desc)
    assert_response :redirect
    assert_redirected_to :controller => 'ticket', :action => 'open'
    t = Ticket.find(ticket.id)
    assert_equal t.description, new_desc        
  end
  
  def test_edit_ticket_manager()
    # Create the ticket to be edited.
    user = users(:manager)
    ticket = create_new_ticket(user.username)    
        
    # Role - manager.
    new_desc = 'Small Town Romance'
    get :edit, {}, {:cas_user => user.username}
    assert_response :redirect 
    post_edit_ticket(ticket, new_desc)
    assert_response :redirect
    assert_redirected_to :controller => 'ticket', :action => 'open'
    t = Ticket.find(ticket.id)
    assert_equal t.description, new_desc        
  end

  def test_close_ticket_bannerite()
    # Create the ticket to be closed.
    user = users(:requestor)
    ticket = create_new_ticket(user.username)    
    assert_not_nil ticket
    user = nil
    
    # Attempt to close the ticket; won't be able.
    user = users(:banner_user)
    get :edit, {}, {:cas_user => user.username}
    close_ticket(ticket)
    assert_response :redirect
    assert_redirected_to :controller => 'login', :action => 'index'
    
    t = Ticket.find(ticket.id)
    assert_equal t.state, State::OPEN
  end
    
  def test_close_ticket_requestor()
    # Create the ticket to be closed.
    user = users(:requestor)
    ticket = create_new_ticket(user.username)    
    
    # Attempt to close the ticket; 
    # shouldn't be able, but can still.
    # This needs to be fixed.
    get :edit, {}, {:cas_user => user.username}
    close_ticket(ticket)
    assert_response :redirect
    assert_redirected_to :controller => 'ticket', :action => :open
          
    t = Ticket.find(ticket.id)
    assert_equal t.state, State::COMPLETE
  end

  def test_close_ticket_coordinator()
    # Create the ticket to be closed.
    user = users(:coordinator)
    ticket = create_new_ticket(user.username)    
    
    # Attempt to close the ticket; 
    # shouldn't be able, but can still.
    # This needs to be fixed.
    get :edit, {}, {:cas_user => user.username}
    close_ticket(ticket)
    assert_response :redirect
    assert_redirected_to :controller => 'ticket', :action => :open
          
    t = Ticket.find(ticket.id)
    assert_equal t.state, State::COMPLETE
  end
  
  def test_close_ticket_requestor()
    # Create the ticket to be closed.
    user = users(:requestor)
    ticket = create_new_ticket(user.username)    
    
    # Attempt to close the ticket; 
    # shouldn't be able, but can still.
    # This needs to be fixed.
    get :edit, {}, {:cas_user => user.username}
    close_ticket(ticket)
    assert_response :redirect
    assert_redirected_to :controller => 'ticket', :action => :open
          
    t = Ticket.find(ticket.id)
    assert_equal t.state, State::COMPLETE
  end
  
  def test_close_ticket_coordinator()
    # Create the ticket to be closed.
    user = users(:coordinator)
    ticket = create_new_ticket(user.username)    
    
    # Attempt to close the ticket; 
    # shouldn't be able, but can still.
    # This needs to be fixed.
    get :edit, {}, {:cas_user => user.username}
    close_ticket(ticket)
    assert_response :redirect
    assert_redirected_to :controller => 'ticket', :action => :open
          
    t = Ticket.find(ticket.id)
    assert_equal t.state, State::COMPLETE
  end
  
  def test_close_ticket_approver()
    # Create the ticket to be closed.
    user = users(:approver)
    ticket = create_new_ticket(user.username)    
    assert_equal State::OPEN, ticket.state
    
    get :edit, {}, {:cas_user => user.username}
    close_ticket(ticket)
    assert_response :redirect
    assert_not_nil assigns(:edit_ticket)
    assert_redirected_to :controller => 'ticket', :action => :open
          
    t = Ticket.find(ticket.id)
    assert_equal t.state, State::COMPLETE
  end
    
  def test_close_ticket_manager()
    # Create the ticket to be closed.
    user = users(:manager)
    ticket = create_new_ticket(user.username)    
    assert_equal State::OPEN, ticket.state
    
    get :edit, {}, {:cas_user => user.username}
    close_ticket(ticket)
    assert_response :redirect
    assert_not_nil assigns(:edit_ticket)
    assert_redirected_to :controller => 'ticket', :action => :open
          
    t = Ticket.find(ticket.id)
    assert_equal t.state, State::COMPLETE
  end
    
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

  def test_index_bannerite()
    get :index, {}, {:cas_user => users(:banner_user).username}
    assert_response :redirect
    assert_redirected_to :controller => 'login', :action => 'index'
    assert_equal @no_permission_msg, flash[:notice]    
  end
  
  def test_index_requestor()
    get :index, {}, {:cas_user => users(:requestor).username}
    assert_response :success
    assert_template 'index'
  end

  def test_index_coordinator()
    get :index, {}, {:cas_user => users(:coordinator).username}
    assert_response :success    
    assert_template 'index'
  end  

  def test_index_approver()
    get :index, {}, {:cas_user => users(:approver).username}
    assert_response :success    
    assert_template 'index'          
  end
  
  def test_index_manager()
    get :index, {}, {:cas_user => users(:manager).username}
    assert_response :success    
    assert_template 'index'      
  end  
    
  def test_new_no_auth()
    get :new
    expected_url = ENV['CAS_BAS_URL'] + "/login?service="
    expected_url += ENV['BAS_URL_ENCODED'] + "%2Fticket%2Fnew"    
    assert_redirected_to expected_url 
    assert_response :redirect
  end  
  
  def test_edit_no_auth()
    get :edit
    expected_url = ENV['CAS_BAS_URL'] + "/login?service="
    expected_url += ENV['BAS_URL_ENCODED'] + "%2Fticket%2Fedit"    
    assert_redirected_to expected_url 
    assert_response :redirect
  end
  
  def test_open_no_auth()
    get :open
    expected_url = ENV['CAS_BAS_URL'] + "/login?service="
    expected_url += ENV['BAS_URL_ENCODED'] + "%2Fticket%2Fopen"    
    assert_redirected_to expected_url 
    assert_response :redirect
  end   
    
  # -----------helpers-------------------
  def post_new_ticket(username = 'duckart', description = 'Testing 4 5 6')
    post  :new, 
          :new_ticket => { 
                          :state => State::OPEN,
                          :username => 'cahana',
                          :description => description,
                          :last_action => 'none',
                          :date => Time.now,
                          :requestor_username => username
                          }
  end
  
  def post_edit_ticket(ticket, description)
    post  :edit,   
          :edit_ticket => { 
                          :username => ticket.username,
                          :description => description,
                          :campus_ids => nil
                          }, 
          :id => ticket.id,
          :save => 'Save'
  end
  
  def close_ticket(ticket, description = Time.now.to_s)
    post  :edit,   
          :edit_ticket => { 
                          :username => ticket.username,
                          :description => description
                          }, 
          :id => ticket.id,
          :commit => 'Close'
  end
  
  def create_new_ticket(requestor_username)
    t = Ticket.new
    t.requestor_username = requestor_username
    t.username = 'drexler'
    t.state = State::OPEN
    t.date = Time.now
    t.save!
    
    return t    
  end
end
