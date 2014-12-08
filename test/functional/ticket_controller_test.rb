require File.dirname(__FILE__) + '/../test_helper'
require 'ticket_controller'
require 'dummy_person_finder'

class TicketControllerTest < ActionController::TestCase
  include ApplicationHelper
  
  fixtures :access_matrix
  fixtures :action_types
  fixtures :campuses
  fixtures :users
  fixtures :tickets
  fixtures :reasons
  fixtures :tasks
  
  APP_TITLE = 'Administer BSAR'
  
  def setup()
    authenticator = LoginHelper::AuthenticatorTestProxy.new() 
    @controller = TicketController.new(authenticator)
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    @request.cookies['_bsar_session_id'] = "fake cookie bypasses filter"
     
    @emails     = ActionMailer::Base.deliveries
    @emails.clear
    
    @controller.person_finder = DummyPersonFinder.new
  end
  
  def test_add_ticket()
    get :new, {}, {:cas_user => users(:duckart).username}
    assert_response :success
    assert_template 'new'
    assert_select 'legend', 'Enter Banner Account Request Details'
    
    ticket_count = Ticket.count
    
    post :new, :new_ticket => { 
                  :state => State::OPEN,
                  :username => 'cahana',
                  :description => 'Testing 4 5 6',
                  :last_action => 'none',
                  :date => Time.now,
                  :requestor_username => 'duckart'
               }

    assert_equal ticket_count + 1, Ticket.count
    
    assert_response :redirect
    assert_redirected_to :action => :new
    get :new

    # Follow what should be the redirect.
    assert_select "div#main" do
      assert_select "div#notice", "Request created."
    end
   
    # Check some values.
    t = Ticket.find(:first, :order => "id desc")
    assert_equal State::OPEN, t.state
    assert_equal 'cahana', t.username
    assert_equal 'duckart', t.requestor_username
    assert_equal 'Testing 4 5 6', t.description
    assert_equal tasks(:new_account).id, t.task_id    
    assert_equal action_types(:none).description, t.last_action
    assert t.is_urgent
    assert_nil t.reason
    assert_equal 0, t.campuses.count    
  end
  
  def test_add_ticket_with_campuses()
    get :new, {}, {:cas_user => users(:duckart).username}
    assert_response :success
    assert_template 'new'
    assert_select 'legend', 'Enter Banner Account Request Details'
    
    maui = campuses(:maui)
    hilo = campuses(:hilo)
    
    ticket_count = Ticket.count
    
    post :new, :new_ticket => { 
                  :state => State::OPEN,
                  :username => 'cahana',
                  :description => 'Testing 4 5 6',
                  :permissions => 'Can do anything.',
                  :last_action => 'none',
                  :date => Time.now,
                  :requestor_username => 'duckart',
                  :add_campus_ids => [hilo.id.to_s, maui.id.to_s]
    }
    
    assert_equal ticket_count + 1, Ticket.count
    assert 'Request created', flash[:notice]
    
    assert_response :redirect
    assert_redirected_to :action => :new    
    get :new

    # Follow what should be the redirect.
    assert_select "div#main" do
      assert_select "div#notice", "Request created."
    end

    # Check some values.
    t = Ticket.find(:first, :order => "id desc")
    assert_equal State::OPEN, t.state
    assert_equal 'cahana', t.username
    assert_equal 'duckart', t.requestor_username
    assert_equal 'Testing 4 5 6', t.description
    assert_equal tasks(:new_account).id, t.task_id    
    assert_equal action_types(:none).description, t.last_action
    assert t.is_urgent
    assert_nil t.reason
    assert_equal 2, t.campuses.count
    assert t.campuses.include?(hilo)
    assert t.campuses.include?(maui)
    
    # Check the outgoing email.
    assert_equal(1, @emails.size)    
    email = @emails.first
    assert_equal('Request to ' + t.task.description.chop(), email.subject)
    assert_equal(EmailAddresses::BIM, email.to[0])
    username_line = 'UH Username: ' + t.username
    assert_match(/#{username_line}/,  email.body)
    assert_match(/Testing 4 5 6/, email.body)
    assert_match(/Can do anything./, email.body)
  end
  
  def test_add_ticket_bad_username()
    get :new, {}, {:cas_user => users(:duckart).username}
    assert_response :success
    assert_template 'new'
    assert_select 'legend', 'Enter Banner Account Request Details'
    
    maui = campuses(:maui)
    hilo = campuses(:hilo)
    
    ticket_count = Ticket.count
    
    post :new, :new_ticket => { 
                  :state => State::OPEN,
                  :username => 'nowayx',
                  :description => 'Testing 4 5 6',
                  :last_action => 'none',
                  :date => Time.now,
                  :requestor_username => 'duckart',
                  :add_campus_ids => [hilo.id.to_s,
                  maui.id.to_s]
               }
    
    assert_response :success
    assert_equal ticket_count, Ticket.count
    assert_select "div#main" do
      assert_select "div#notice", "The UH Username 'nowayx' not valid."
    end
  end
  
  def test_add_close()
    get :new, {}, {:cas_user => users(:duckart).username}
    
    post_new_ticket()
    
    t = Ticket.find(:first, :order => "id desc")
    assert_equal TaskType::NEW_ACCOUNT, t.task.id    
    ticket_count = Ticket.count
    
    post_close_ticket(t)
    assert_response :redirect
    assert_redirected_to :action => 'open'
    get :open

    assert_select "body#admin" do
      assert_select 'div#banner', 'BSAR Administration'          end    
    
    assert_select "div#main" do
      assert_select "div#notice", 'Request was successfully updated.'    end  
    
    t = Ticket.find(t.id)
    task_description = t.task.description.chop
    
    # Check ticket count (no change after close), 
    # state (=closed) and # of emails (=2)
    assert_equal ticket_count, Ticket.count  
    assert_equal State::COMPLETE, t.state
    assert_equal TaskType::NEW_ACCOUNT, t.task.id
    
    assert_equal(2, @emails.size)  #add and close
    
    email = @emails.first
    assert_equal('Request to ' + task_description, email.subject)
    assert_equal(EmailAddresses::BIM, email.to[0])
    
    email = @emails.last
    assert_equal('Completed ' + task_description, email.subject)
    assert_equal(EmailAddresses::REGISTRAR, email.to[0])
    username_line = 'UH Username: ' + t.username
    assert_match(/#{username_line}/,  email.body)
  end 
  
  def test_add_close_edit()
    get :new, {}, {:cas_user => users(:duckart).username}
    
    post_new_ticket()
    
    ticket_count = Ticket.count
    t = Ticket.find(:first, :order => "id desc")
    assert_equal TaskType::NEW_ACCOUNT, t.task.id
    
    post_close_ticket(t)
    
    t = Ticket.find(t.id)
    windward = campuses(:windward)
    
    post_edit_campus(t, windward)
    
    t = Ticket.find(t.id)
    
    # Should not have changed because close and edit.
    assert_equal ticket_count, Ticket.count
    
    # Should edit on closed be allowed?
    assert_equal State::COMPLETE, t.state
    
    # Two emails should be generated.
    assert_equal(2, @emails.size)    
  end
  
  def test_edit_campuses()
    get :new, {}, {:cas_user => users(:duckart).username}
    assert_response :success
    
    maui = campuses(:maui)
    hilo = campuses(:hilo)    
    create_with_campuses(TaskType::NEW_ACCOUNT, [maui, hilo]) 
    
    t = Ticket.find(:first, :order => "id desc")
    assert t.campuses.include?(Campus.find(campuses(:maui).id))
    assert t.campuses.include?(Campus.find(campuses(:hilo).id))
    
    post_edit_campus(t, campuses(:windward))
    assert_response :redirect
    t = Ticket.find(:first, :conditions => "id = #{t.id}")
    
    assert_equal State::OPEN, t.state
    assert_equal t.username, t.username
    assert_equal 1, t.campuses.count   
    assert t.campuses.include?(Campus.find(campuses(:windward).id))
    assert !t.campuses.include?(Campus.find(campuses(:maui).id))
    assert !t.campuses.include?(Campus.find(campuses(:hilo).id))
    
    # 1 email for add
    assert_equal(1, @emails.size)        
  end
  
  def test_delete_campus()
    maui = campuses(:maui)
    hilo = campuses(:hilo)
    
    get :new, {}, {:cas_user => users(:duckart).username}
    create_with_campuses(TaskType::NEW_ACCOUNT, [maui, hilo])
    t = Ticket.find(:first, :order => "id desc")
    assert_equal 2, t.campuses.count
    assert t.campuses.include?(hilo)
    assert t.campuses.include?(maui)
    ticket_count = Ticket.count
    post_delete_campus(t)
    
    #check count, is campuses removed, # of emails (add, edit =1) 
    assert_equal ticket_count, Ticket.count
    t = Ticket.find(:first, :conditions => "id = #{t.id}")
    assert_equal 0, t.campuses.count   
    assert_equal(1, @emails.size)        
  end
  
  def test_add_ticket_no_user()
    get :new, {}, {:cas_user => users(:duckart).username}
    assert_response :success
    assert_template 'new'
    assert_select 'legend', 'Enter Banner Account Request Details'
    
    ticket_count = Ticket.count
    
    post :new, 
    :new_ticket => { :state => State::OPEN,
      :username => '',
      :description => 'Testing 4 5 6',
      :last_action => 'none',
      :date => Time.now,
      :requestor_username => 'duckart'
    }
    
    assert_response :success
    assert_equal ticket_count, Ticket.count
    
    assert_select "div#main" do
      assert_select "div#notice", "You did not enter a UH Username."
    end
    
    assert_equal(0, @emails.size)
  end
  
  def test_add_close_close()
    #user hits close button two times - two emails should not be generated
    get :new, {}, {:cas_user => users(:duckart).username}
    post_new_ticket()
    t = Ticket.find(:first, :order => "id desc")
    assert_equal TaskType::NEW_ACCOUNT, t.task.id    
    task_description = t.task.description.chop
    
    assert_equal(1, @emails.size)  
    @emails.clear
    
    post_close_ticket(t)
    assert_response :redirect
    get :open
    assert_select "div#main" do
      assert_select "div#notice", "Request was successfully updated."
    end
    
    post_close_ticket(t)
    assert_response :redirect
    get :open
    assert_select "div#main" do
      assert_select "div#notice", "Request was successfully updated."      
    end   
    
    assert_equal(2, @emails.size)  
    
    email = @emails.first
    assert_equal('Completed ' + task_description, email.subject)
    assert_equal(t.requestor_email(), email.to[0])
    
    email = @emails.last
    assert_equal('Completed ' + task_description, email.subject)
    assert_equal(t.requestor_email(), email.to[0])  
  end
  
  def test_edit_new_check_tags()
    get :new, {}, {:cas_user => users(:duckart).username}
    post_new_ticket()
    t = Ticket.find(:first, :order => "id desc")
    assert_equal State::OPEN, t.state
    assert_equal TaskType::NEW_ACCOUNT, t.task.id
    
    get :edit, {:id => t.id}, {:cas_user => users(:duckart).username}
    assert_response :success
    assert_template 'ticket/edit'
    
    action_path = "/bsar/ticket/edit/#{t.id}" 
    tag = find_tag(:tag => 'form', :attributes => {:action => action_path})
    
    assert_equal 'post', tag.attributes['method']  
    assert_equal action_path, tag.attributes['action']
    assert_select 'title', APP_TITLE
    assert_select 'legend', 'Edit Account Request'
    
    assert_select "div#main" do
      assert_select "table" do
        assert_select "tr" , :count => 10
        assert_select "tr.username-row td:first-of-type", "UH Username:"
        assert_select "tr.username-row td:last-of-type", t.username
        assert_select "tr.requesttype-row td:first-of-type", "Request Type:"
        assert_select "tr.requesttype-row td:last-of-type", t.task.name
        assert_select "tr.submit-row" do
          assert_select "td:last-of-type" do           
            assert_select "input", :count => 2
            assert_select "input:first-of-type" do  
              assert_select "input[name=save][value~=Save without Closing]"
            end
            assert_select "input:last-of-type" do 
              assert_select "input[name=commit][value~=Close and Notify Requestor]"
            end
          end
        end
      end
    end
  end
  
  def test_edit_modify_check_tags()
    get :new, {}, {:cas_user => users(:duckart).username}
    post_new_ticket(TaskType::MODIFY_ACCOUNT)
    t = Ticket.find(:first, :order => "id desc")
    assert_equal State::OPEN, t.state
    assert_equal TaskType::MODIFY_ACCOUNT, t.task.id
    
    get :edit, {:id => t.id}, {:cas_user => users(:duckart).username}
    assert_response :success
    assert_template 'ticket/edit'
    
    action_path = "/bsar/ticket/edit/#{t.id}" 
    tag = find_tag(:tag => 'form', :attributes => {:action => action_path})
    
    assert_equal 'post', tag.attributes['method']  
    assert_equal action_path, tag.attributes['action']
    assert_select 'title', APP_TITLE
    assert_select 'legend', 'Edit Account Request'
    
    assert_select "div#main" do
      assert_select "table" do
        assert_select "tr" , :count => 10
        assert_select "tr.username-row td:first-of-type", "UH Username:"
        assert_select "tr.username-row td:last-of-type", t.username
        assert_select "tr.requesttype-row td:first-of-type", "Request Type:"
        assert_select "tr.requesttype-row td:last-of-type", t.task.name
        assert_select "tr.submit-row" do
          assert_select "td:last-of-type" do           
            assert_select "input", :count => 2
            assert_select "input:first-of-type" do  
              assert_select "input[name=save][value~=Save without Closing]"
            end
            assert_select "input:last-of-type" do 
              assert_select "input[name=commit][value~=Close and Notify Requestor]"
            end
          end
        end
      end
    end
  end
 
  def test_closed_view_check_tags()
    get :new, {}, {:cas_user => users(:duckart).username}
    post_new_ticket(TaskType::MODIFY_ACCOUNT)
    t = Ticket.find(:first, :order => "id desc")
    assert_equal TaskType::MODIFY_ACCOUNT, t.task.id
    
    post_close_ticket(t)
    t = Ticket.find(:first, :order => "id desc")
    assert_equal State::COMPLETE, t.state
    
    get :edit, {:id => t.id}, {:cas_user => users(:duckart).username}
    assert_response :success
    assert_template 'ticket/edit'
    
    action_path = "/bsar/ticket/edit/#{t.id}" 
    tag = find_tag(:tag => 'form', :attributes => {:action => action_path})
    
    assert_equal 'post', tag.attributes['method']  
    assert_equal action_path, tag.attributes['action']
    assert_select 'title', APP_TITLE
    assert_select 'legend', 'View Account Request'
    
    assert_select "div#main" do
      assert_select "table" do
        assert_select "tr" , :count => 9
        assert_select "tr.username-row td:first-of-type", "UH Username:"
        assert_select "tr.username-row td:last-of-type", t.username
        assert_select "tr.requesttype-row td:first-of-type", "Request Type:"
        assert_select "tr.requesttype-row td:last-of-type", t.task.name  
      end
    end
  end
    
  def test_view_closed_check_tags()
    get :new, {}, {:cas_user => users(:duckart).username}
    post_new_ticket()
    t = Ticket.find(:first, :order => "id desc")
    assert_equal State::OPEN, t.state
    assert_equal TaskType::NEW_ACCOUNT, t.task.id
    
    post_close_ticket(t)
    t = Ticket.find(:first, :order => "id desc")
    get :edit, {:id => t.id}, {:cas_user => users(:duckart).username}
    assert_response :success
    assert_template 'ticket/edit'
    
    action_path = "/bsar/ticket/edit/#{t.id}" 
    tag = find_tag(:tag => 'form', :attributes => {:action => action_path})
    
    assert_equal 'post', tag.attributes['method']  
    assert_equal action_path, tag.attributes['action']
    assert_select 'title', APP_TITLE
    assert_select 'legend', 'View Account Request'
    
    assert_select "div#main" do
      assert_select "table" do
        assert_select "tr" , :count => 9
        assert_select "tr.username-row td:first-of-type", "UH Username:"
        assert_select "tr.username-row td:last-of-type", t.username 
      end
    end
  end

  def test_add_ticket_no_state()
    # Verifying that ticket added with no state will be created and defaulted 
    # to open email should be generated.
    get :new, {}, {:cas_user => users(:duckart).username}
    ticket_count = Ticket.count
    
    post :new, 
    :new_ticket => { 
      :username => 'cahana',
      :description => 'Testing again',
      :last_action => 'none',
      :date => Time.now,
      :requestor_username => 'duckart'
    }
    
    
    assert_response :redirect
    assert_equal ticket_count+1, Ticket.count
    
    # Check some values.
    t = Ticket.find(:first, :order => "id desc")
    assert_equal State::OPEN, t.state
    assert_equal 'cahana', t.username
    assert_equal 'duckart', t.requestor_username
    assert_equal 'Testing again', t.description
    
    
    assert_equal(1, @emails.size)
    email = @emails.first
    assert_equal('Request to ' + t.task.description.chop, email.subject)
    assert_equal(EmailAddresses::BIM, email.to[0])
  end
  
  def test_invalid_ticket_id()
    get :new, {}, {:cas_user => users(:duckart).username}
    post_new_ticket()
    
    t = Ticket.find(:first, :order => "id desc")
    assert_equal TaskType::NEW_ACCOUNT, t.task.id
    
    get :edit, {:id => t.id}, {:cas_user => users(:duckart).username}
    assert_response :success
    assert_template 'ticket/edit'
    
    get :edit, {:id => 555555}, {:cas_user => users(:duckart).username}
    assert_response :redirect
    assert_redirected_to :action => 'open'
    
    get :edit, {:id => 'abc'}, {:cas_user => users(:duckart).username}
    assert_response :redirect
    assert_redirected_to :action => 'open'
    
    get :edit, {:id => 'delete from tickets'}, 
               {:cas_user => users(:duckart).username}
    assert_response :redirect
    assert_redirected_to :action => 'open'
    
    id = t.id
    
    # Check adding sql statement in field.
    ticket_count = Ticket.count
    windward = campuses(:windward)
    edit_description = t.description + '; ' + Time.now.to_s
    post :edit,   :edit_ticket => { 
      :username => 'delete from tickets',
      :description => edit_description,
      :campus_ids => [windward.id.to_s]}, 
    :id => t.id,
    :save => 'Save'
    
    assert_response :redirect
    assert_nil flash[:notice]
    assert_redirected_to :action => 'open'
    t = Ticket.find(:first, :order => "id desc")
    
    # Check that edit was successful.
    assert_equal "delete from tickets", t.username
     
    # No change in number of tickets.
    assert_equal ticket_count, Ticket.count  
    
    # Check using sql statement in id field, 
    # should not update ticket, verify both id and username.
    edit_description = t.description + '; ' + Time.now.to_s
    post :edit,   :edit_ticket => { 
      :username => 'cahana',
      :description => edit_description,
      :campus_ids => [windward.id.to_s]}, 
    :id => 'delete from tickets',
    :save => 'Save'
    
    assert_response :redirect
    assert_nil flash[:notice]
    assert_redirected_to :action => 'open'
    assert_equal ticket_count, Ticket.count
    
    t = Ticket.find(:first, :order => "id desc")
    assert_equal id, t.id  #id should be the same as before
    assert_equal 'delete from tickets', t.username
  end

  #-----------------------------------------------------------------------------
  private 
  
  def post_new_ticket(task_id = TaskType::NEW_ACCOUNT)
    post :new, :new_ticket => { 
                 :state => State::OPEN,
                 :username => 'cahana',
                 :description => 'Testing 4 5 6',
                 :permissions => 'Can do anything.',
                 :last_action => 'none',
                 :date => Time.now,
                 :task_id => task_id,
                 :requestor_username => 'duckart'
    }
  end
  
  def create_with_campuses(task_id = TaskType::NEW_ACCOUNT, campuses = nil)
    post :new, :new_ticket => { 
                  :state => State::OPEN,
                  :username => 'cahana',
                  :description => 'Testing 4 5 6',
                  :permissions => 'Can do anything.',
                  :last_action => 'none',
                  :date => Time.now,
                  :requestor_username => 'duckart',
                  :task_id => task_id,
                  :add_campus_ids => campuses 
               }
  end
  
  def post_edit_campus(ticket, campus)
    edit_description = ticket.description + '; ' + Time.now.to_s
    post :edit, :edit_ticket => { :username => ticket.username,
                                  :description => edit_description,
                                  :campus_ids => [campus.id.to_s]
                                }, 
                :id => ticket.id,
                :save => 'Save'
  end
  
  def post_delete_campus(ticket)
    edit_description = ticket.description + '; ' + Time.now.to_s
    post :edit, :edit_ticket => { :username => ticket.username,
                                  :description => edit_description,
                                  :campus_ids => nil
                                }, 
                :id => ticket.id,
                :save => 'Save'
  end
  
  def post_close_ticket(ticket)
    edit_description = ticket.description + '; ' + Time.now.to_s
    post :edit, :edit_ticket => { :username => ticket.username,
                                  :description => edit_description
                                }, 
                :id => ticket.id,
                :commit => 'Close'
  end
  
end
