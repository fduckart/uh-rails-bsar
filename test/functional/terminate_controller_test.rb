require File.dirname(__FILE__) + '/../test_helper'
require 'terminate_controller'
require 'dummy_person_finder'

class TerminateControllerTest < Test::Unit::TestCase
  include ApplicationHelper
  
  fixtures :reasons
  fixtures :tickets
  fixtures :tasks
  fixtures :users
  fixtures :access_matrix
  
  def setup()
    authenticator = LoginHelper::AuthenticatorTestProxy.new() 
    @controller = TerminateController.new(authenticator)
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    @request.cookies['_bsar_session_id'] = "fake cookie bypasses filter"
    
    @emails     = ActionMailer::Base.deliveries
    @emails.clear
    
    @controller.person_finder = DummyPersonFinder.new
  end
  
  def test_missing_reason()
    get :new, {}, {:cas_user => users(:duckart).username}
    assert_response :success
    assert_template 'new'
    
    req_count = Ticket.count
    
    # Note, 'reason' is missing from post.
    post :new, :new_ticket => { 
      :state => State::OPEN,
      :username => 'cahana',
      :description => 'Testing 1 2 3',
      :date => Time.now
    }
    
    assert_response :success
    assert_equal req_count, Ticket.count
    assert_tag :tag => 'div', :attributes => {:id => 'notice'}, 
               :child => TerminateController::ERRORS['empty_reason']
  end
  
  def test_missing_username()
    get :new, {}, {:cas_user => users(:duckart).username}
    assert_response :success
    assert_template 'new'
    
    req_count = Ticket.count
    
    # Note, 'username' is missing from post.
    post :new, :new_ticket => { 
                  :requestor_username => 'duckart', 
                  :state => 'new',
                  :description => 'Testing 1 2 3',
                  :date => Time.now,
                  :reason => reasons(:separated).id
               }
    
    assert_response :success
    assert_equal req_count, Ticket.count
    
    assert_tag :tag => 'div', :attributes => {:id => 'notice'}, 
               :child => TerminateController::ERRORS['empty_username']
  end
  
  def test_missing_state()
    get :new, {}, {:cas_user => users(:duckart).username}
    assert_response :success
    assert_template 'new'
    
    req_count = Ticket.count
    
    # Note, 'state' is missing from post.
    post :new, :new_ticket => { 
                  :requestor_username => 'duckart', 
                  :username => 'cahana', 
                  :description => 'Testing 1 2 3',
                  :date => Time.now,
                  :reason => reasons(:separated).id
               }
    
    # Note that we succesfully saved the new record
    # because state has as default value of State::OPEN.                     
    assert_response :redirect
    assert_redirected_to :action => :new, :controller => 'terminate'    
    assert_equal req_count + 1, Ticket.count
    
    # Check some values.
    br = Ticket.find(:first, :order => "id desc")
    assert_equal State::OPEN, br.state
    assert_equal 'cahana', br.username
    assert_equal 'duckart', br.requestor_username
    assert_equal 'Testing 1 2 3', br.description
    assert_equal 1, br.reason
  end
  
  def test_username_not_found_via_ldap()
    def @controller.lookup_cas_user(username)
      return nil  # Pretend we didn't find the user via LDAP.
    end
    
    get :new, {}, {:cas_user => users(:duckart).username}
    assert_response :success
    assert_template 'new'
    
    req_count = Ticket.count
    post :new, :new_ticket => { 
                  :state => State::OPEN,
                  :username => 'nobody',
                  :description => 'Testing 1 2 3',
                  :date => Time.now,
                  :reason => reasons(:separated).id
               }
    
    assert_equal req_count, Ticket.count
    assert_response :success
    assert_equal req_count, Ticket.count
    assert_tag :tag => 'div', :attributes => {:id => 'notice'}, 
               :child => "The UH Username 'nobody' not valid."
  end
  
  def test_requestor_new_request()
    user = users(:requestor)
    get :new, {}, {:cas_user => user.username}
    assert_response :success
    assert_template 'new'
  end
  
  def test_requestor_closed_request()
    user = users(:requestor)
    get :closed, {}, {:cas_user => user.username}
    assert_response :redirect
    assert_redirected_to :action => :index, :controller => :login
  end
  
  def test_add_ticket()
    user = users(:duckart)
    get :new, {}, {:cas_user => user.username}
    assert_response :success
    assert_template 'new'
    
    req_count = Ticket.count
    post :new, :new_ticket => { 
                  :state => State::OPEN,
                  :username => 'cahana',
                  :description => 'Testing 1 2 3',
                  :date => Time.now,
                  :reason => reasons(:separated).id
                }
    
    assert_response :redirect
    assert_equal req_count + 1, Ticket.count
    
    # Check some values.
    br = Ticket.find(:first, :order => "id desc")
    assert_equal State::OPEN, br.state
    assert_equal 'cahana', br.username
    assert_equal 'duckart', br.requestor_username
    assert_equal 'Testing 1 2 3', br.description
    assert_equal 1, br.reason
    
    # Check the outgoing email.
    assert_equal(1, @emails.size)    
    email = @emails.first
    
    assert_equal('Request to ' + br.task.description.chop(), email.subject)
    assert_equal(EmailAddresses::BIM, email.to[0])
    username_line = 'UH Username: ' + br.username
    assert_match(/#{username_line}/,  email.body)
  end
  
  def test_add_ticket_with_trimming()
    get :new, {}, {:cas_user => users(:duckart).username}
    assert_response :success
    assert_template 'new'
    
    req_count = Ticket.count
    post :new, 
    :new_ticket => { 
      :state => ' ' + State::OPEN + '   ',
      :username => 'cahana  ',
      :description => 'Testing 1 2 3',
      :date => Time.now,
      :reason => reasons(:separated).id
    }
    
    assert_response :redirect
    assert_equal req_count + 1, Ticket.count
    
    # Check some values.
    br = Ticket.find(:first, :order => "id desc")
    assert_equal State::OPEN, br.state
    assert_equal 'cahana', br.username
    assert_equal 'duckart', br.requestor_username
    assert_equal 'Testing 1 2 3', br.description
    assert_equal 1, br.reason
  end
  
  def test_edit_ticket_save()
    ticket = Ticket.find(:first, 
                         :conditions => ["task_id = 2 and state = 'open'"])
    assert_not_nil ticket.username
    assert_not_nil ticket.description
    assert ticket.username.length > 0
    assert ticket.description.length > 0
    assert_equal State::OPEN, ticket.state
    
    get :edit, {:id => ticket.id}, {:cas_user => users(:duckart).username}
    assert_response :success
    
    action_path = "/bsar/terminate/edit/#{ticket.id}" 
    tag = find_tag(:tag => "form", :attributes => {:action => action_path})
    
    assert_equal 'post', tag.attributes['method']  
    assert_equal action_path, tag.attributes['action']
    assert_select 'title', 'Administer BSAR'
    
    assert_select "div#main" do
      assert_select "table" do
        assert_select "tr" , :count => 5
        assert_select "tr.username-row td:last-of-type", ticket.username
        assert_select "tr.comments-row td:last-of-type", ticket.description
      end
    end
    
    assert_equal 0, @emails.size    
    
    ticket_count = Ticket.count
    edit_description = '<note>' + ticket.description + '</note>'
    
    post :edit, :edit_ticket => { 
                  :username => ticket.username,
                  :description => edit_description}, 
         :id => ticket.id,
         :save => 'Save'
    
    assert_response :redirect
    assert_redirected_to :action => :open, :controller => 'ticket'
    
    assert_equal ticket_count, Ticket.count
    
    # Check some values.
    t = Ticket.find(:first, :conditions => "id = #{ticket.id}")
    assert_equal State::OPEN, t.state
    assert_equal ticket.username, t.username
    assert_equal ticket.requestor_username, t.requestor_username
    assert_equal edit_description, t.description
    
    # Make sure we don't have any outgoing email.
    assert_equal(0, @emails.size)    
  end
  
  def test_edit_ticket_check_tags()
    ticket_count = Ticket.count
    user = users(:duckart)
    get :new, {}, {:cas_user => user.username}
    assert_response :success
    assert_template 'new'
    
    conditions = "task_id = 2 and state = 'open'"
    ticket = Ticket.find(:first, :conditions => conditions)
    assert_equal State::OPEN, ticket.state
    
    get :edit, {:id => ticket.id}, {:cas_user => users(:duckart).username}
    assert_response :success
    assert_template 'edit'
    
    action_path = "/bsar/terminate/edit/#{ticket.id}" 
    tag = find_tag(:tag => 'form', :attributes => {:action => action_path})
    
    assert_equal 'post', tag.attributes['method']  
    assert_equal action_path, tag.attributes['action']
    assert_select 'title', 'Administer BSAR'
    assert_select 'legend', 'Edit Request to Terminate Banner Access'
    assert_equal ticket_count, Ticket.count
    
    assert_select "div#main" do
      assert_select "table" do
        assert_select "tr" , :count => 5
        assert_select "tr.username-row td:first-of-type", "UH Username to terminate:"
        assert_select "tr.username-row td:last-of-type", ticket.username
        assert_select "tr.comments-row td:last-of-type", ticket.description
        assert_select "tr.submit-row" do
          assert_select "td:last-of-type" do           
            assert_select "input", :count => 2
            assert_select "input:first-of-type" do  
              assert_select "input[name=save][value~=Save without Closing]"
            end
            assert_select "input:last-of-type" do 
              assert_select "input[name=commit][value~=Close Request]"
            end
          end
        end
      end
    end
  end
  
  def test_edit_ticket_close()
    ticket = Ticket.find(:first, 
                         :conditions => ["task_id = 2 and state = 'open'"])
    assert_not_nil ticket.username
    assert_not_nil ticket.description
    assert ticket.username.length > 0
    assert ticket.description.length > 0
    assert_equal State::OPEN, ticket.state
    
    get :edit, {:id => ticket.id}, {:cas_user => users(:duckart).username}
    assert_response :success
    assert_template 'edit'
    
    assert_equal 0, @emails.size    
    
    ticket_count = Ticket.count
    edit_description = '<note>' + ticket.description + '</note>'
    
    post :edit, :edit_ticket => { 
                  :username => ticket.username,
                  :description => edit_description}, 
         :id => ticket.id,
         :commit => 'Close'
    
    assert_response :redirect
    assert_redirected_to :action => :open, :controller => 'ticket'    
    assert_equal ticket_count, Ticket.count
    
    # Check some values.
    t = Ticket.find(:first, :conditions => "id = #{ticket.id}")
    assert_equal 'complete', t.state
    assert_equal ticket.username, t.username
    assert_equal ticket.requestor_username, t.requestor_username
    assert_equal edit_description, t.description
    
    # Check the outgoing email.
    assert_equal(1, @emails.size)    
    email = @emails.first
    task_description = t.task.description.chop()
    assert_equal('Completed ' + task_description, email.subject)
    assert_equal(t.requestor_email(), email.to[0])
    username_line = 'UH Username: ' + t.username
    assert_match(/#{username_line}/,  email.body)
  end
  
  def test_edit_invalid_ticket_id()
    # Test adding, editing and searching for invalid id's.
    get :new, {}, {:cas_user => users(:duckart).username}
    assert_response :success
    post_new_ticket()
    
    t = Ticket.find(:first, :order => "id desc")
    get :edit, {:id => t.id}, {:cas_user => users(:duckart).username}
    assert_response :success
    assert_template 'terminate/edit'
    
    get :edit, {:id => 555555}, {:cas_user => users(:duckart).username}
    assert_response :redirect
    assert_redirected_to :action => :open, :controller => 'ticket'
    
    get :edit, {:id => 'abc'}, {:cas_user => users(:duckart).username}
    assert_response :redirect
    assert_redirected_to :action => :open, :controller => 'ticket'
   
    get :edit, {:id => 'delete from tickets'}, 
               {:cas_user => users(:duckart).username}
    assert_response :redirect
    assert_redirected_to :action => :open, :controller => 'ticket'
    
    ticket_count = Ticket.count
    get :edit, {:id => 'delete from tickets'}, 
               {:cas_user => users(:duckart).username}
    assert_redirected_to :controller => 'ticket', :action => 'open'
    # No change in ticket count.
    assert_equal ticket_count, Ticket.count 
  end
  
  def test_search()
    get :search, {}, {:cas_user => users(:duckart).username}
    assert_response :success
  end
  
  def test_edit_ticket_with_sql()
    get :new, {}, {:cas_user => users(:duckart).username}
    assert_response :success
    post_new_ticket()
    assert_response :redirect
    assert_equal "Termination Request created.", flash[:notice] 
    
    t = Ticket.find(:first, :order => "id desc")
    ticket_count = Ticket.count
    
    # Test putting sql in different columns.
    post :edit,   
         :edit_ticket => { 
                         :username => 'delete from tickets',
                         :copy_username => 'delete from tickets',
                         :requestor_username => 'delete from tickets',
                         :state => 'none',
                         :permissions => "'delete from tickets",
                         :last_action => 'delete from tickets',
                         :description => 'delete from tickets'
                         }, 
        :id => t.id,
        :save => 'Save'
    
    # edit should be a success but no action should 
    # be triggered bases on the sql statement.
    assert_response :redirect
    assert_equal "Request was successfully updated.", flash[:notice]
    assert_equal ticket_count, Ticket.count
    
    t = Ticket.find(:first, :order => "id desc")
    
    #check that edits was successful
    assert_equal "delete from tickets", t.username        
    assert_equal "delete from tickets", t.requestor_username
    
    # Model requires state to be complete, none, or open, so 
    # so cannot test sql on field  
    assert_equal "none", t.state  
    assert_equal "'delete from tickets", t.permissions  
    assert_equal "delete from tickets", t.last_action
    assert_equal "delete from tickets", t.description   
    assert_equal "delete from tickets", t.copy_username
    
    # Check to ensure the delete did not execute.
    assert_equal ticket_count, Ticket.count
  end
  
  def test_cookies_disabled()
    @request.cookies['_bsar_session_id'] = nil
    get :new, {}, {:cas_user => users(:duckart).username}
    assert_response :redirect
    assert_redirected_to :action => 'new', :cookies_enabled => 'checked'
  end

  #-----------------------------------------------------------------------------
  private
  
  def post_new_ticket()
    post :new, :new_ticket => { :state => State::OPEN,
                                :username => 'cahana',
                                :description => 'Testing 1 2 3',
                                :date => Time.now,
                                :reason => reasons(:separated).id
                              }
  end
  
end
