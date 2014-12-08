class BannerRequestController < ApplicationController
  
  layout "admin"
  before_filter :check_access_privileges
  
  def count() end  
  def destroy() end
  def edit() end
  def new() end
  def open() end      
  def pwd_only() end
  def update() end
  ############################################

=begin
           
  TYPE_USERNAME = "uid"
  TYPE_USERID   = "uhuuid"
  
  def count
    @total_tickets = Ticket.count
  end
  
  def open()
    begin
      condition = "state = '#{State::OPEN}'" 
      @open_tickets = Ticket.find(:all, :conditions => condition)
    rescue Exception => ex
      logger.error(ex)
    end
  end
  
  def new()
    begin
      @current_user = get_current_user()
      
      has_errors = false
      if request.post?
        @new_ticket = Ticket.new(params[:new_ticket])
        
        # Guard to check if username is there and valid.
        username = @new_ticket.username
        if Strings.is_nil_or_empty(username)
          flash_notice(ERRORS['empty_username'])
          has_errors = true
        else    
          username = username.strip
          user = lookup_cas_user(username)
          if user.nil?
            flash_notice("The UH Username '#{username}' not valid.")
            has_errors = true
          end
        end
        
        if has_errors
          return  # Exit now.                
        end
        
        @new_ticket.state = State::NONE
        @new_ticket.date=Date.today
        @new_ticket.last_action = State::NONE
        @new_ticket.requestor_username = get_current_username()
        
        if (@new_ticket.save!)           
          logger.info "NEW ticket created for " + username
          redirect_to(:action => :edit, :id => @new_ticket.id)        
        end        
      end
    rescue Exception => ex
      puts ex
      logger.error(ex)
      flash[:notice] = ex.to_s
      redirect_to(:action => :new)
    end
    
  end
  def pwd_only()
    begin
      @current_user = get_current_user()
      
      has_errors = false
      if request.post?
        cancel = cancel_clicked?(params)
        if cancel
          redirect_to :controller => 'login', :action => :index
          
        else
          
          @new_ticket = Ticket.new(params[:new_ticket])
          
          # Guard to check if username is there and valid.
          username = @new_ticket.username
          if Strings.is_nil_or_empty(username)
            flash_notice(ERRORS['empty_username'])
            has_errors = true
          else    
            username = username.strip
            user = lookup_cas_user(username)
            if user.nil?
              flash_notice("The UH Username '#{username}' not valid.")
              has_errors = true
            end
          end
          
          if has_errors
            return  # Exit now.                
          end
          
          @new_ticket.state = State::OPEN
          @new_ticket.date=Date.today
          @new_ticket.last_action = State::NONE
          @new_ticket.task_id=3
          @new_ticket.requestor_username = get_current_username()
          
          if (@new_ticket.save!)           
            email_request(@new_ticket,user)
            flash[:notice] = 'Password reset request was successfully submitted.' 
            redirect_to(:controller => 'login', :action => :index)        
          end 
        end
      end
    rescue Exception => ex
      puts ex
      logger.error(ex)
      flash[:notice] = ex.to_s
      redirect_to(:action => :pwd_only)
    end
    
  end
  
  def edit()    
    begin
      id = params[:id].to_i
      @edit_ticket = Ticket.find(id)
      @campuses = Campus.find(:all)
      @person =lookup_cas_user(@edit_ticket.username)
      
      if !@edit_ticket.nil?
        
        if (request.post?)
          
          cancel = cancel_clicked?(params)
          if cancel
            redirect_to :action => :open
            
          else
            if (@edit_ticket.task_id == 1 || @edit_ticket.task_id == 6)
              # check if the username entered to be copied from is valid.
              ticket = Ticket.new(params[:edit_ticket])
              if (!Strings.is_nil_or_empty(ticket.copy_username))
                if (lookup_cas_user(ticket.copy_username.strip).nil?)
                  msg = "The UH Username '#{ticket.copy_username.strip}' entered " 
                  msg += "to copy permissions from is not valid."
                  flash_notice(msg)  
                  return
                end
              end
            end 
            
            new = false
            if @edit_ticket.state == State::NONE
              new=true
              @edit_ticket.state = State::OPEN
            end
            
            close = close_clicked?(params)
            if (close)
              @edit_ticket.state = State::COMPLETE
              logger.info "ticket CLOSED: " + @edit_ticket.id  + "by user: " + session[:cas_user]
            end
            
            @edit_ticket.campuses.clear if @edit_ticket.campuses
            
            # Save the update.
            if @edit_ticket.update_attributes(params[:edit_ticket]) 
              if new || close
                user = lookup_cas_user(@edit_ticket.username)
                email_request(@edit_ticket,user)
              end
              flash[:notice] = 'Request was successfully entered.' if new
              flash[:notice] = 'Request was successfully closed.' if close
              flash[:notice] = 'Request was successfully updated.' if !new && !close
              
              redirect_to :action => :open
            else
              render :action => 'edit'
            end
          end
        end
      else
        raise exception
      end
    rescue Exception => ex
      logger.error(ex)
      redirect_to :action => :edit 
    end
  end
  
  def update()
    @ticket = Ticket.find(params[:id])
    if @ticket.update_attributes(params[:req])
      flash[:notice] = 'Request was successfully updated.'
      redirect_to :action => 'open'
    else
      render :action => 'edit'
    end
  end 
  
  def destroy()
    if request.post?
      req = Ticket.find(params[:id])
      begin
        req.destroy
        flash[:notice] = "Request deleted."
      rescue
        flash[:notice] = e.message
      end
    end
    redirect_to :action => :open
  end
  
  #-----------------------------------------------------------------------------  
  private
  
  def email_request(ticket,user)
    begin
      BannerRequestMailer.send_ticket(ticket,user)
    rescue Exception => ex
      puts ex
      logger.error(ex)
    end  
    
  end
  
  def flash_notice(text)
    if flash.now[:notice]
      flash.now[:notice] << "<br/>#{text}"
    else
      flash.now[:notice] = text
    end
  end
  
  def close_clicked?(params)
    begin
      close = (params[:commit].nil? == false)
    rescue Exception
      close = false
    end
    return close
  end
  
  def cancel_clicked?(params)
    begin
      cancel = (params[:cancel].nil? == false)
    rescue Exception
      cancel = false
    end
    return cancel
  end
  
=end  

end
