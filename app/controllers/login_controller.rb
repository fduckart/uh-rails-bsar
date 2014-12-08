class LoginController < ApplicationController

  layout 'admin'
  
  before_filter :check_access_privileges, :except => [:index, :login, :logout]  
  
  def add_user()
    @system_roles = Role.find_system_roles.map {|u| [u.name.capitalize, u.id]}
     
    if request.post?        
      @user = User.new(params[:user])    
      
      # Guard to check if user entered UH ID.
      if @user.username.empty?
        msg = "You must enter a UH Username."
        flash[:notice] = msg
        redirect_to(:action => :add_user)      
        
        return  # Exit now.
      end

      # Guard to check if user is in this system.
      if !(User.find_by_username(@user.username).nil?)
        msg = "The UH Username '#{@user.username}' " 
        msg += "already exists in this system."
        flash[:notice] = msg
        redirect_to(:action => :add_user)      
        
        return  # Exit now.
      end
            
      # Guard to make sure username is in LDAP directory.
      if lookup_cas_user(@user.username).nil?
        msg = "'#{@user.username}' is not a valid UH Username."
        flash[:notice] = msg
        redirect_to(:action => :add_user)      
        
        return  # Exit now.        
      end
      
      # Save the record.      
      if @user.save!
        flash.now[:notice] = "User #{@user.username} created."
        @user = User.new
        uri = session[:original_uri]
        session[:original_uri] = nil
        redirect_to(uri || {:action => :list_users})
      end
    end
  end

  def logout(url = ENV['BAS_URL'] + '/login/index')
    begin      
      reset_session
      clear_page_vars
      redirect_to CASClient::Frameworks::Rails::Filter.client.logout_url(url)
    rescue Exception => ex
      logger.error("LoginController.logout; exception: " + ex.to_s)
    end
  end

  def index()
    # Main index/welcome page.
    begin
      bas_url = ENV['BAS_URL']
      logger.info("BAS_URL: #{bas_url}")
    rescue Exception => ex
      logger.error("Error: " + ex.to_s)
    end
    
  end
  
  def lookup_user()
    if request.post? and !params[:value].empty?
      value = params[:value].strip
      type = params[:type]

      value.each_char { |c| 
        if !(c =~ /\w/)
          error = "Error: only letters or digits are allowed."
          flash.now[:notice] = error
          
          return         
        end
      }
      
      @cas_user = lookup_cas_user(value, type)
      if @cas_user.nil?
        flash.now[:notice] = "'" + value.to_s + "' was not found."
      end
    end
    
  end
  
  def delete_user()
    if request.post?
      user = User.find(params[:id])
      begin
        user.destroy
        flash[:notice] = "User #{user.username} deleted."
      rescue
        flash[:notice] = e.message
      end
    end
    redirect_to(:action => :list_users)
  end

  def list_users()
    @system_users = 
      User.find(:all,
                :joins => "inner join roles as r on users.role_id = r.id",
                :order => "username asc")
  end

  def login_user()
    home = 'index'  # Possible replace this with a lookup.
    redirect_to(:action => home)
  end
  
  # ----------------------------------------------------------------------------
  # Used only in testing.
  def login()
    session[:cas_user] = nil
    
    if request.post?
      clear_page_vars
      user = User.authenticate(params[:username])
      if user
        session[:cas_user] = user.username
        
        # Cache some common looked-up user fields.
        person = lookup_cas_user(user.username)
        if person
          session[:title] = person.title
          session[:phone] = person.phone
        end
        
        uri = session[:original_uri]
        session[:original_uri] = nil
        home = user_home(user) 
        redirect_to(uri || {:action => home})
      else
        flash.now[:notice] = "Invalid user."        
      end
    end
  end
  # ----------------------------------------------------------------------------
  
end
