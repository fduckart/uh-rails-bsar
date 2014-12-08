# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.
require 'cgi'

class ApplicationController < ActionController::Base
  include ApplicationHelper

  before_filter :cookies_required
  before_filter :authenticate_user,  :except => [:index, :login, :logout]
  before_filter :verify_user, :except => [:index, :login, :logout]  
  before_filter :set_page_vars
  
  TYPE_USERNAME = "uid"       # Move this somewhere shareable.
  TYPE_USERID   = "uhuuid"    # Move this somewhere shareable.

  session :session_key => '_bsar_session_id'
  attr_accessor :authenticator
  attr_writer :person_finder
  
  public 

  def cookies_required()
    if request.cookies["_bsar_session_id"].to_s.blank?
      if params[:cookies_enabled].nil?
        redirect_to :controller => params[:controller], :action => params[:action], :cookies_enabled => "checked"
      else
        flash[:notice] = "Cookies Disabled" 
        render :layout => 'layouts/cookies_disabled',  :template => 'shared/cookies_disabled'
      end 
    end 
  end

  def get_person_finder()
    if @person_finder.nil?
      @person_finder = PersonLookupController.new
    end
    return @person_finder
  end

  def authenticate_user()
    return @authenticator.authenticate_user
  end
    
  def initialize(authenticator = nil)
    super()
    @authenticator = authenticator || LoginHelper::Authenticator.new
    @authenticator.controller = self 
  end
  
  def get_current_username()
    cas_user = session[:cas_user]
    if (cas_user)
      cas_user = cas_user.split(/[\r|\n]/)[0].strip
      if (cas_user)
        session[:cas_user] = cas_user
      end 
    end
    
    return cas_user
  end
  
  def get_current_user()
    return User.find_by_username(get_current_username())
  end
  
  def verify_user()
    user = get_current_user()
    if (user.nil?) 
      redirect_to(:action => :index, :controller => 'login')
    end
  end

  def check_access_privileges()
    user = get_current_user()
    allowed = AccessMatrixLookup.find(user, self)
    if (!allowed)
      flash[:notice] = 'You do not have permissions to view that resource.'
      redirect_to(:action => :index, :controller => 'login')
    end 
  end
   
  def clear_page_vars()
    @user = nil
    @user_home = nil
    @session_cas_user = nil
  end
  
  def set_page_vars()    
    clear_page_vars()
    
    username = get_current_username()  
    if username
      @user = User.find_by_username(username)
      if @user
        @user_home = user_home(@user)
        @session_cas_user = session[:cas_user]
      end
    end
    
    @is_cas_logged_in = !username.nil? && !username.strip.empty?
  end
  
  def lookup_cas_user(value, type = TYPE_USERNAME)
    plc = get_person_finder() 
    if TYPE_USERNAME.eql?(type)
      user = plc.lookup_by_username(value)
    else                
      user = plc.lookup_by_userid(value)
    end
    
    return user
  end

  def redirect_to_ex(uri) 
    redirect_to uri
  end
  
  #----------------------------------------------------------------------------
  private 
  
  def user_home(user)
    if user.nil? or user.role.nil?
      home = 'index'
    else
      home = user.role.home
    end
    return home
  end
  
  #----------------------------------------------------------------------------
  
end
