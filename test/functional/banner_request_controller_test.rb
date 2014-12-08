require 'test_helper'

class BannerRequestControllerTest < ActionController::TestCase
  include ApplicationHelper
  
  fixtures :access_matrix
  fixtures :action_types
  fixtures :campuses
  fixtures :users
  fixtures :tickets
  fixtures :reasons
  fixtures :tasks
  
  APP_TITLE = 'Administer BSAR'
  
  def setup
    authenticator = LoginHelper::AuthenticatorTestProxy.new() 
    @controller = BannerRequestController.new(authenticator)
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    @request.cookies['_bsar_session_id'] = "fake cookie bypasses filter"
    
    @emails     = ActionMailer::Base.deliveries
    @emails.clear
    
    @controller.person_finder = DummyPersonFinder.new
  end
  
=begin  
  def test_add_new_request()

    user = users(:duckart)
    
    # Check the first screen that shows up.
    get :new, {}, {:cas_user => user.username}
    assert_response :success
    assert_template 'new'
    assert_select 'legend', 'Enter Banner Request'
    
    ticket_count = Ticket.count
    
    post_new_request(TaskType::NEW_ACCOUNT)
    t = Ticket.find(:first, :order => "id desc")
    assert_equal ticket_count + 1, Ticket.count
    assert_response :redirect
    expected_url = '/banner_request/edit/' + t.id.to_s
    assert_redirected_to expected_url   
    
    # Check some values.
    assert_equal State::NONE, t.state
    assert_equal 'cahana', t.username
    assert_nil t.description
    assert_equal TaskType::NEW_ACCOUNT, t.task_id    
    assert_equal action_types(:none).description, t.last_action
    assert_equal true, t.is_urgent
    assert_nil t.reason
    assert_equal 0, t.campuses.count
    assert_equal(0, @emails.size)  
    
    # Check the second entry screen.
    get :edit, {:id => t.id}, {:cas_user => user.username}
    assert_response :success
    assert_template 'banner_request/edit'
    
    action_path = "/banner_request/edit/#{t.id}" 
    tag = find_tag(:tag => 'form', :attributes => {:action => action_path})
    assert_equal 'post', tag.attributes['method']  
    assert_equal action_path, tag.attributes['action']
    assert_select 'title', :text => APP_TITLE, :count => 1
    assert_select 'legend', /Enter([\n\r])*New Account Request/
    
    # Complete new ticket and then follow 
    # what should be the redirect.
    post_edit(t)
    assert_response :redirect
    assert_redirected_to :action => :open
    get :open
    assert_select "div#main" do
      assert_select "div#notice", "Request was successfully entered."
    end
    
    # Make sure only Save button
    
    # Check the outgoing email.
    assert_equal(1, @emails.size)    
    email = @emails.first
    assert_equal('Request to Create Banner Account', email.subject)
    assert_equal(EmailAddresses::BIM, email.to[0])
  end
  
  def test_add_modify_request()
    # Check the first screen that shows up.    
    get :new, {}, {:cas_user => users(:duckart).username}
    assert_response :success
    assert_template 'new'
    assert_select 'legend', /Enter([\s])*Banner Request/
    
    ticket_count = Ticket.count
    
    post_new_request(6)
    t = Ticket.find(:first, :order => "id desc")
    assert_equal ticket_count + 1, Ticket.count
    assert_response :redirect
    expected_url = '/banner_request/edit/' + t.id.to_s
    assert_redirected_to expected_url   
    
    # Check some values.
    assert_equal State::NONE, t.state
    assert_equal 'cahana', t.username
    assert_nil t.description
    assert_equal tasks(:modify_account).id, t.task_id    
    assert_equal action_types(:none).description, t.last_action
    assert_equal true, t.is_urgent
    assert_nil t.reason
    assert_equal 0, t.campuses.count
    assert_equal(0, @emails.size)  
    
    # Check the second entry screen.
    get :edit, {:id => t.id}, {:cas_user => users(:duckart).username}
    assert_response :success
    assert_template 'banner_request/edit'
    action_path = "/banner_request/edit/#{t.id}" 
    tag = find_tag(:tag => 'form', :attributes => {:action => action_path})    
    assert_equal 'post', tag.attributes['method']  
    assert_equal action_path, tag.attributes['action']
    assert_select 'title', :text => APP_TITLE, :count => 1
    assert_select 'legend', /Enter([\s])*Modify Account Request/
      
    # Make sure the buttons are there.
    assert_select "tr.submit-row" do
      assert_select "td:last-of-type" do           
        assert_select "input", :count => 2
        
        assert_select "input:first-of-type" do  
          assert_select "input[name=save][value~=Save]"
        end
        
        assert_select "input:last-of-type" do 
          assert_select "input[name=cancel][value~=Cancel]"
        end
        
      end
    end 
    
    # Complete new ticket and then follow 
    # what should be the redirect.
    post_edit(t)
    assert_response :redirect
    assert_redirected_to :action => :open
    get :open  # Follow what should be the redirect.
    assert_select "div#main" do
      assert_select "div#notice", "Request was successfully entered."
    end
           
    # Check the outgoing email.
    assert_equal(1, @emails.size)    
    email = @emails.first
    assert_equal('Request to Modify Banner Account', email.subject)
    assert_equal(EmailAddresses::BIM, email.to[0])
  end
  
  def test_add_pwdreset_request()
    # Check the first screen.
    get :new, {}, {:cas_user => users(:duckart).username}
    assert_response :success
    assert_template 'new'
    assert_select 'legend', 'Enter Banner Request'
    
    ticket_count = Ticket.count
    
    post_new_request(3)
    t = Ticket.find(:first, :order => "id desc")
    assert_equal ticket_count + 1, Ticket.count
    assert_response :redirect
    expected_url = '/banner_request/edit/' + t.id.to_s
    assert_redirected_to expected_url   
    
    # Check some values.
    assert_equal State::NONE, t.state
    assert_equal 'cahana', t.username
    assert_nil t.description
    assert_equal tasks(:reset_password).id, t.task_id    
    assert_equal action_types(:none).description, t.last_action
    assert_equal true, t.is_urgent
    assert_nil t.reason
    assert_equal 0, t.campuses.count
    assert_equal(0, @emails.size)  
    
    # Check the second entry screen.
    get :edit, {:id => t.id}, {:cas_user => users(:duckart).username}
    assert_response :success
    assert_template 'banner_request/edit'    
    action_path = "/banner_request/edit/#{t.id}" 
    tag = find_tag(:tag => 'form', :attributes => {:action => action_path})
    assert_equal 'post', tag.attributes['method']  
    assert_equal action_path, tag.attributes['action']
    assert_select 'title', APP_TITLE
    assert_select 'legend', /Enter([\s])*Reset Password Request/
      
    # Make sure the buttons are there.
    assert_select "tr.submit-row" do
      assert_select "td:last-of-type" do           
        assert_select "input", :count => 2
        
        assert_select "input:first-of-type" do  
          assert_select "input[name=save][value~=Save]"
        end
        
        assert_select "input:last-of-type" do 
          assert_select "input[name=cancel][value~=Cancel]"
        end
        
      end
    end 
            
    # Complete new ticket entry, post, and follow the redirect.  
    post_edit(t)
    assert_response :redirect
    assert_redirected_to :action => :open
    get :open  # Follow what should be the redirect.
    assert_select "div#main" do
      assert_select "div#notice", "Request was successfully entered."
    end
    
    # Check the outgoing email.
    assert_equal(1, @emails.size)    
    email = @emails.first
    assert_equal('Request to Reset Password for Banner Account', email.subject)
    assert_equal(EmailAddresses::BIM, email.to[0])
  end
    
  def test_add_terminate_request()
    # Check the first screen.
    get :new, {}, {:cas_user => users(:duckart).username}
    assert_response :success
    assert_template 'new'
    assert_select 'legend', 'Enter Banner Request'
    
    ticket_count = Ticket.count
    
    post_new_request(2)
    t = Ticket.find(:first, :order => "id desc")
    assert_equal ticket_count + 1, Ticket.count
    assert_response :redirect
    expected_url = '/banner_request/edit/' + t.id.to_s
    assert_redirected_to expected_url   
    
    # Check some values.
    assert_equal State::NONE, t.state
    assert_equal 'cahana', t.username
    assert_nil t.description
    assert_equal tasks(:terminate_account).id, t.task_id    
    assert_equal action_types(:none).description, t.last_action
    assert_equal true, t.is_urgent
    assert_nil t.reason
    assert_equal 0, t.campuses.count
    assert_equal(0, @emails.size)  
    
    # Check the second entry screen.
    get :edit, {:id => t.id}, {:cas_user => users(:duckart).username}
    assert_response :success
    assert_template 'banner_request/edit'
    action_path = "/banner_request/edit/#{t.id}" 
    tag = find_tag(:tag => 'form', :attributes => {:action => action_path})
    assert_equal 'post', tag.attributes['method']  
    assert_equal action_path, tag.attributes['action']
    assert_select 'title', APP_TITLE
    assert_select 'legend', /Enter([\s])*Terminate Account Request/
      
    # Make sure the buttons are there.
    assert_select "tr.submit-row" do
      assert_select "td:last-of-type" do           
        assert_select "input", :count => 2
        
        assert_select "input:first-of-type" do  
          assert_select "input[name=save][value~=Save]"
        end
        
        assert_select "input:last-of-type" do 
          assert_select "input[name=cancel][value~=Cancel]"
        end
        
      end
    end 
    
    # Complete new ticket entry, post, and follow the redirect.  
    post_edit(t)
    assert_response :redirect
    assert_redirected_to :action => :open
    get :open   # Follow what should be the redirect.
    assert_select "div#main" do
      assert_select "div#notice", "Request was successfully entered."
    end
    
    # Check the outgoing email.
    assert_equal(1, @emails.size)    
    email = @emails.first
    assert_equal('Request to Terminate Banner Account', email.subject)
    assert_equal(EmailAddresses::BIM, email.to[0])
  end

  def test_add_pwdresetonly_request()
    #  Check the first screen.
    get :pwd_only, {}, {:cas_user => users(:duckart).username}
    assert_response :success
    assert_template 'pwd_only'
    assert_select 'legend', 'Reset Banner Password'
          
    # Make sure the buttons are there.
    assert_select "tr.submit-row" do
      assert_select "td:last-of-type" do           
        assert_select "input", :count => 2
        
        assert_select "input:first-of-type" do  
          assert_select "input[name=save][value~=Submit]"
          assert true
        end
        
        assert_select "input:last-of-type" do 
          assert_select "input[name=cancel][value~=Cancel]"
        end
        
      end
    end 
    
    ticket_count = Ticket.count
    
    post :pwd_only, :new_ticket => { 
                        :username => 'cahana',
                        :task_id => TaskType::RESET_PASSWORD,
                        :requestor_username => 'duckart'
    }
    
    t = Ticket.find(:first, :order => "id desc")
    assert_equal ticket_count + 1, Ticket.count
    assert_response :redirect
    expected_url = '/login/index/'
    assert_redirected_to expected_url   
    assert 'Password reset request was successfully submitted.', flash[:notice]
    
    # Check some values.
    assert_equal State::OPEN, t.state
    assert_equal 'cahana', t.username
    assert_nil t.description
    assert_equal tasks(:reset_password).id, t.task_id    
    assert_equal action_types(:none).description, t.last_action
    assert_equal true, t.is_urgent
    assert_nil t.reason
    assert_equal 0, t.campuses.count
    assert_equal(1, @emails.size)  
    
    # Check the outgoing email.
    email = @emails.first
    assert_equal('Request to Reset Password for Banner Account', email.subject)
    assert_equal(EmailAddresses::BIM, email.to[0])
  end

  def test_add_no_user_entered()
    # Add a new account request.
    ticket_count = Ticket.count
    get :new, {}, {:cas_user => users(:duckart).username}
    post :new, :new_ticket => { 
                   :username => nil,
                   :task_id => TaskType::NEW_ACCOUNT,
                   :requestor_username => 'duckart'
                }
    assert_response :success
    assert 'You did not enter a UH Username', flash[:notice]
    assert_equal ticket_count, Ticket.count
    
    # Add a terminate account request.
    ticket_count = Ticket.count
    get :new, {}, {:cas_user => users(:duckart).username}
    post :new, :new_ticket => { 
                    :username => nil,
                    :task_id => TaskType::REMOVE_ACCOUNT,
                    :requestor_username => 'duckart'
               }
    assert_response :success
    assert 'You did not enter a UH Username', flash[:notice]
    assert_equal ticket_count, Ticket.count
    
    # Add password reset request.
    ticket_count = Ticket.count
    get :new, {}, {:cas_user => users(:duckart).username}
    post :new, :new_ticket => { 
                   :username => nil,
                   :task_id => TaskType::RESET_PASSWORD,
                  :requestor_username => 'duckart'
               }
    assert_response :success
    assert 'You did not enter a UH Username', flash[:notice]
    assert_equal ticket_count, Ticket.count
    
    # Add a modify request.
    ticket_count = Ticket.count
    get :new, {}, {:cas_user => users(:duckart).username}
    post :new, :new_ticket => { 
                   :username => nil,
                   :task_id => TaskType::MODIFY_ACCOUNT,
                   :requestor_username => 'duckart'
               }
    assert_response :success
    assert 'You did not enter a UH Username', flash[:notice]
    assert_equal ticket_count, Ticket.count
    
    # Add password reset only page
    ticket_count = Ticket.count
    get :pwd_only, {}, {:cas_user => users(:duckart).username}
    post :pwd_only, :new_ticket => { 
                        :username => nil,
                        :task_id => TaskType::RESET_PASSWORD,
                        :requestor_username => 'duckart'
                    }
    assert_response :success
    assert 'You did not enter a UH Username', flash[:notice]
    assert_equal ticket_count, Ticket.count
    
    assert_equal(0, @emails.size)     
  end
  
  def test_add_unknown_username()
    #add new
    ticket_count = Ticket.count
    get :new, {}, {:cas_user => users(:duckart).username}
    post :new, 
    :new_ticket => { 
      :username => 'babababa',
      :task_id => 1,
      :requestor_username => 'duckart'
    }
    assert_response :success
    assert "The UH Username 'babababa' not valid.", flash[:notice]
    assert_equal ticket_count, Ticket.count
    
    #add terminate
    ticket_count = Ticket.count
    get :new, {}, {:cas_user => users(:duckart).username}
    post :new, 
    :new_ticket => { 
      :username => 'babababa',
      :task_id => 2,
      :requestor_username => 'duckart'
    }
    assert_response :success
    assert "The UH Username 'babababa' not valid.", flash[:notice]
    assert_equal ticket_count, Ticket.count
    
    #add password reset
    ticket_count = Ticket.count
    get :new, {}, {:cas_user => users(:duckart).username}
    post :new, 
    :new_ticket => { 
      :username => 'babababa',
      :task_id => 3,
      :requestor_username => 'duckart'
    }
    assert_response :success
    assert "The UH Username 'babababa' not valid.", flash[:notice]
    assert_equal ticket_count, Ticket.count
    
    #add modify
    ticket_count = Ticket.count
    get :new, {}, {:cas_user => users(:duckart).username}
    post :new, 
    :new_ticket => { 
      :username => 'babababa',
      :task_id => 6,
      :requestor_username => 'duckart'
    }
    assert_response :success
    assert "The UH Username 'babababa' not valid.", flash[:notice]
    assert_equal ticket_count, Ticket.count
    
    #add password reset only page
    ticket_count = Ticket.count
    get :pwd_only, {}, {:cas_user => users(:duckart).username}
    post :pwd_only, 
    :new_ticket => { 
      :username => "'drop table tickets",
      :task_id => 3,
      :requestor_username => 'duckart'
    }
    assert_response :success
    assert "The UH Username 'babababa' not valid.", flash[:notice]
    assert_equal ticket_count, Ticket.count
    
    #no emails
    assert_equal(0, @emails.size)   
  end
  
#  def test_add_no_task_entered()
#    #add new - task id is required -add should not be successfull
#    ticket_count = Ticket.count
#    get :new, {}, {:cas_user => users(:duckart).username}
#    post :new, 
#    :new_ticket => { 
#      :username => 'amek',
#      :task_id => nil,
#      :requestor_username => 'duckart'
#    }
#    
#    t = Ticket.find(:first, :order => "id desc")
#    assert_response :redirect
#    expected_url = '/banner_request/new'
#    assert "Validation failed: Task can't be blank", flash[:notice]
#    assert_equal ticket_count, Ticket.count
#    assert_equal(0, @emails.size) 
#    
#    #pwd reset only - automatically sets ticket type to 3
#    ticket_count = Ticket.count
#    get :pwd_only, {}, {:cas_user => users(:duckart).username}
#    post :pwd_only, 
#    :new_ticket => { 
#      :username => 'amek',
#      :task_id => nil,
#      :requestor_username => 'duckart'
#    }
#    
#    assert_response :redirect
#    expected_url = '/login/index'
#    assert_redirected_to expected_url   
#    
#    # Check some values
#    t = Ticket.find(:first, :order => "id desc")
#    assert_equal State::OPEN, t.state
#    assert_equal tasks(:reset_password).id, t.task_id    
#    assert_equal 'amek', t.username
#    assert_equal ticket_count+1, Ticket.count
#    assert_equal(1, @emails.size)
#    email = @emails.first
#    assert_equal('Request to Reset Password for Banner Account', email.subject)
#    assert_equal(EmailAddresses::REGISTRAR, email.to[0])
#    username_line = 'UH Username: ' + t.username
#    
#  end
  
#  def test_add_invalid_task()
#    #add new - task id is required -add should not be successfull
#    ticket_count = Ticket.count
#    get :new, {}, {:cas_user => users(:duckart).username}
#    post :new, 
#    :new_ticket => { 
#      :username => 'amek',
#      :task_id => 25,
#      :requestor_username => 'duckart'
#    }
#    
#    t = Ticket.find(:first, :order => "id desc")
#    assert_response :redirect
#    expected_url = '/banner_request/new'
#    #not really the correct message - since a task is entered although not valid
#    assert "Validation failed: Task can't be blank", flash[:notice]
#    assert_equal ticket_count, Ticket.count
#    assert_equal(0, @emails.size) 
#  end
    
  def test_add_invalid_task_pwd_reset_only()
    # Add new pwd reset request - task id is invalid but controller 
    # sets it to pwd_reset by default ticket should be added.
    ticket_count = Ticket.count
    get :pwd_only, {}, {:cas_user => users(:duckart).username}
    post :pwd_only, 
    :new_ticket => { 
      :username => 'amek',
      :task_id => 25,
      :requestor_username => 'duckart'
    }
    
    t = Ticket.find(:first, :order => "id desc")
    expected_url = '/login/index/'
    assert_redirected_to expected_url   
    assert 'Password reset request was successfully submitted.', flash[:notice]
    
    # Check some values.
    assert_equal State::OPEN, t.state
    assert_equal 'amek', t.username
    assert_nil t.description
    assert_equal tasks(:reset_password).id, t.task_id    
    assert_equal action_types(:none).description, t.last_action
    assert_equal true, t.is_urgent
    assert_nil t.reason
    assert_equal 0, t.campuses.count
    assert_equal(1, @emails.size)  
    
    #check email
    email = @emails.first
    assert_equal('Request to Reset Password for Banner Account', email.subject)
    assert_equal(EmailAddresses::BIM, email.to[0])
    username_line = 'UH Username: ' + t.username
  end
  
  def test_add_pwdresetonly_sql_in_description()
    #    #first screen
    get :pwd_only, {}, {:cas_user => users(:duckart).username}
    assert_response :success
    assert_template 'pwd_only'
    assert_select 'legend', 'Reset Banner Password'
    
    ticket_count = Ticket.count
    
    post :pwd_only, :new_ticket => { 
      :username => 'cahana',
      :task_id => 3,
      :description => "'drop database bsar_test;",
      :requestor_username => 'duckart'
    }
    
    t = Ticket.find(:first, :order => "id desc")
    assert_equal ticket_count + 1, Ticket.count
    assert_response :redirect
    expected_url = '/login/index/'
    assert_redirected_to expected_url   
    assert 'Password reset request was successfully submitted.', flash[:notice]
    
    # Check some values.
    assert_equal "'drop database bsar_test;", t.description
    assert_equal tasks(:reset_password).id, t.task_id    
    assert_equal(1, @emails.size)  
  end
  
  def test_add_pwdresetonly_numbers_in_description()
    #    #first screen
    get :pwd_only, {}, {:cas_user => users(:duckart).username}
    assert_response :success
    assert_template 'pwd_only'
    assert_select 'legend', 'Reset Banner Password'
    
    ticket_count = Ticket.count
    
    post :pwd_only, 
    :new_ticket => { 
      :username => 'cahana',
      :task_id => 3,
      :description => 5566778899,
      :requestor_username => 'duckart'
    }
    
    t = Ticket.find(:first, :order => "id desc")
    assert_equal ticket_count + 1, Ticket.count
    assert_response :redirect
    expected_url = '/login/index/'
    assert_redirected_to expected_url   
    assert 'Password reset request was successfully submitted.', flash[:notice]
    
    # Check some values.
    assert_equal '5566778899', t.description
    assert_equal tasks(:reset_password).id, t.task_id    
    assert_equal(1, @emails.size)  
    
  end
  
  def test_permissions_to_add_new()
    #need to set access matrix prior to testing this
  end
  def test_permissions_to_add_modify()
    #need to set access matrix prior to testing this
  end
  def test_permissions_to_add_terminate()
    #need to set access matrix prior to testing this
  end
  def test_permissions_to_add_pwd_only()
    #need to set access matrix prior to testing this
  end
  def test_permissions_to_add_pwd_only_for_logged_in_user()
    #user must be CAS authenticated but do not need a role in the system
  end
  
  #--------test edit on all tickets types
  def test_edit_request_type_1_tags()
    get :new, {}, {:cas_user => users(:duckart).username}
    post_new_request(1)
    t = Ticket.find(:first, :order => "id desc")
    post_edit(t)
    
    #set up is done, now test
    @emails.clear
    ticket_count = Ticket.count
    get :edit, {:id => t.id}, {:cas_user => users(:duckart).username}
    
    #check fields
    assert_response :success
    assert_template 'banner_request/edit'
    
    action_path = "/banner_request/edit/#{t.id}" 
    tag = find_tag(:tag => 'form', :attributes => {:action => action_path})
    
    assert_equal 'post', tag.attributes['method']  
    assert_equal action_path, tag.attributes['action']
    assert_equal 'edit_form', tag.attributes['name']
    assert_select 'title', APP_TITLE
    assert_select 'legend', /Edit([\s])*New Account Request/
    
    assert_select "div#main" do
      assert_select "table" do
        assert_select "tr" , :count => 12
        assert_select "tr.requesttype-row td:first-of-type", "Request Type:"
        assert_select "tr.requesttype-row td:last-of-type", t.task.name
        
        #this particular user should have three buttons at this time
        
        assert_select "tr.submit-row" do
          assert_select "td:last-of-type" do           
            assert_select "input", :count => 3
            
            assert_select "input:first-of-type" do  
              assert_select "input[name=save][value~=Save without Closing]"
            end
            
            assert_select "input:last-of-type" do 
              assert_select "input[name=cancel][value~=Cancel]"
            end
            
          end
        end
      end
    end
  end
  
  def test_edit_request_type_1()
    get :new, {}, {:cas_user => users(:duckart).username}
    post_new_request(1)
    t = Ticket.find(:first, :order => "id desc")
    post_edit(t)
    
    #set up is done, now test
    @emails.clear
    ticket_count = Ticket.count
    t = Ticket.find(:first, :order => "id desc")
    post_edit_description(t)
    assert_response :redirect
    assert_redirected_to :action => :open
    
    # Follow redirect for the flash message
    get :open
    assert_select "div#main" do
      assert_select "div#notice", "Request was successfully updated."
    end
    
    #no new ticket, no new email sent and updated field recorded
    assert_equal(0, @emails.size)    
    t = Ticket.find(:first, :order => "id desc")
    assert_equal ticket_count , Ticket.count
    assert_equal 'i changed', t.description
  end
  
  def test_edit_campuses_new()
    get :new, {}, {:cas_user => users(:duckart).username}
    post_new_request(1)
    t = Ticket.find(:first, :order => "id desc")
    post_edit(t)
    
    #set up is done, now test
    @emails.clear
    ticket_count = Ticket.count
    t = Ticket.find(:first, :order => "id desc")
    ticket_count = Ticket.count
    
    maui = campuses(:maui)
    hilo = campuses(:hilo)    
    
    post_edit_with_campuses(t,[maui.id.to_s,hilo.id.to_s])
    
    assert_equal ticket_count, Ticket.count
    
    assert_response :redirect
    assert_redirected_to :action => :open
    get :open
    
    # Follow what should be the redirect.
    assert_select "div#main" do
      assert_select "div#notice", "Request was successfully updated."
    end
    
    # Check some values.
    t = Ticket.find(:first, :order => "id desc")
    assert_equal State::OPEN, t.state  
    assert_equal 2, t.campuses.count
    assert t.campuses.include?(hilo)
    assert t.campuses.include?(maui)
    # no email expected - should have been sent during setup
    assert_equal(0, @emails.size)    
  end
  
  def test_edit_campuses_modify()
    get :new, {}, {:cas_user => users(:duckart).username}
    post_new_request(6)
    t = Ticket.find(:first, :order => "id desc")
    post_edit(t)
    
    #set up is done, now test
    @emails.clear
    ticket_count = Ticket.count
    t = Ticket.find(:first, :order => "id desc")
    ticket_count = Ticket.count
    
    maui = campuses(:maui)
    hilo = campuses(:hilo)    
    
    post_edit_with_campuses(t,[maui.id.to_s,hilo.id.to_s])
    
    assert_equal ticket_count, Ticket.count
    assert 'Request created', flash[:notice]
    
    assert_response :redirect
    assert_redirected_to :action => :open
    get :open
    
    # Follow what should be the redirect.
    assert_select "div#main" do
      assert_select "div#notice", "Request was successfully updated."
    end
    
    # Check some values.
    t = Ticket.find(:first, :order => "id desc")
    assert_equal State::OPEN, t.state  
    assert_equal 2, t.campuses.count
    assert t.campuses.include?(hilo)
    assert t.campuses.include?(maui)
    # no email expected - should have been sent during setup
    assert_equal(0, @emails.size)    
  end
  
  def test_delete_campus()   
    get :new, {}, {:cas_user => users(:duckart).username}
    post_new_request(1)
    t = Ticket.find(:first, :order => "id desc")
    post_edit(t)
    
    #set up is done, now test
    @emails.clear
    ticket_count = Ticket.count
    t = Ticket.find(:first, :order => "id desc")
    ticket_count = Ticket.count
    
    maui = campuses(:maui)
    hilo = campuses(:hilo)    
    
    post_edit_with_campuses(t,[maui.id.to_s,hilo.id.to_s])
    t = Ticket.find(:first, :order => "id desc")
    assert_equal 2, t.campuses.count
    
    #test setup, test
    ticket_count = Ticket.count
    post_edit_delete_campus(t)
    assert_response :redirect
    assert_redirected_to :action => :open
    get :open
    
    # Follow what should be the redirect.
    assert_select "div#main" do
      assert_select "div#notice", "Request was successfully updated."
    end
    
    #check count, is campuses removed, no emails
    assert_equal ticket_count, Ticket.count
    t = Ticket.find(:first, :conditions => "id = #{t.id}")
    assert_equal 0, t.campuses.count   
    assert_equal(0, @emails.size)        
  end
    
  # -----------helpers-------------------
  def post_new_request(task_id = TaskType::NEW_ACCOUNT)
    post :new, :new_ticket => { 
                   :username => 'cahana',
                   :task_id => task_id,
                   :requestor_username => 'duckart'
               }
  end
  
  def post_edit(ticket)
    post :edit, :edit_ticket => { 
                    :state => State::OPEN,
                    :description => 'Testing 4 5 6',
                    :permissions => 'Can do anything.',
                    :last_action => 'none',
                },
         :id => ticket.id,
         :save => 'Save'
  end
  
  def post_edit_description(ticket)
    post :edit, :edit_ticket => { 
      :state => State::OPEN,
      :description => 'i changed',
      :permissions => 'Can do anything.',
      :last_action => 'none',
    },
    :id => ticket.id,
    :save => 'Save'
  end
  
  def post_edit_with_campuses(ticket, campuses)
    post :edit, :edit_ticket => { 
      :state => State::OPEN,
      :username => 'cahana',
      :description => 'Testing 4 5 6',
      :permissions => 'Can do anything.',
      :last_action => 'none',
      :date => Time.now,
      :requestor_username => 'duckart',
      :campus_ids => campuses 
    },
    :id => ticket.id,
    :save => 'Save'
  end
  
  def post_edit_campus(ticket, campus)
    post :edit,   :edit_ticket => { 
      :username => ticket.username,
      :description => 'clicked save',
      :campus_ids => [campus.id.to_s]}, 
    :id => ticket.id,
    :save => 'Save'
  end
  
  def post_edit_delete_campus(ticket)
    post :edit,   :edit_ticket => { 
      :username => ticket.username,
      :description => 'clicked save',
      :campus_ids => nil}, 
    :id => ticket.id,
    :save => 'Save'
  end
  
  def post_cancel_ticket(ticket)
    post :edit,   :edit_ticket => { 
      :username => ticket.username,
      :description => 'clicked cancel'}, 
    :id => ticket.id,
    :commit => 'Cancel'
  end
  
  def post_close_ticket(ticket)
    post :edit,   :edit_ticket => { 
      :username => ticket.username,
      :description => 'clicked close'}, 
    :id => ticket.id,
    :commit => 'Close'
  end
=end
  
end
