class TicketController < ApplicationController
  
  layout "admin"
  before_filter :check_access_privileges
  
  TYPE_USERNAME = "uid"
  TYPE_USERID   = "uhuuid"
  
  def count()
    @total_tickets = Ticket.count
  end
  
  def index()
    @ticket_count = Ticket.count
    @tickets = Ticket.find(:all)    
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
  
  def edit()    
    begin
      id = params[:id].to_i
      conditions = ["id = ? and task_id != ?", id, TaskType::REMOVE_ACCOUNT]      
      @edit_ticket = Ticket.find(:first, :conditions => conditions)
      @campuses = Campus.find(:all)
           
      if !@edit_ticket.nil?
        if (request.post?)
          ticket = Ticket.new(params[:edit_ticket])
          
          # Check if the username entered to be copied from is valid.
          if (!Strings.is_nil_or_empty(ticket.copy_username))
            if (lookup_cas_user(ticket.copy_username.strip).nil?)
              msg = "The UH Username '#{ticket.copy_username.strip}' entered " 
              msg += "to copy permissions from is not valid."
              flash_notice(msg)  
              return
            end
          end
          
          close = close_clicked?(params)
          if (close)
            @edit_ticket.state = State::COMPLETE
          end
          
          # Campuses hack. (There has to be a better way.)
          @edit_ticket.campuses.clear if @edit_ticket.campuses
          
          # Save the update.
          if (@edit_ticket.update_attributes(params[:edit_ticket]))
            if (close)
              user = lookup_cas_user(@edit_ticket.username)
              email_completed_ticket(@edit_ticket,user)
            end
            flash[:notice] = 'Request was successfully updated.'
            redirect_to :action => :open
          else
            render :action => 'edit'
          end
        end
      else
        raise exception
      end
    rescue Exception => ex
      logger.error(ex)
      redirect_to :action => :open
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
    redirect_to(:action => :coordinator_view)
  end
 
  def new()
    begin
      @current_user = get_current_user()
      @campuses = Campus.find(:all)
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
          
          # Check if the username entered to be copied from is valid.
          if (!Strings.is_nil_or_empty(@new_ticket.copy_username))
            copy_username = @new_ticket.copy_username.strip
            copy_user = lookup_cas_user(copy_username)
            if (copy_user.nil?)
              msg = "The UH Username '#{copy_username}' entered to " + 
              msg += "copy permissions from is not valid."
              flash_notice(msg)
              has_errors = true
            end
          end
        end
                
        if has_errors
          return  # Exit now.                
        end
        
        @new_ticket.state = State::OPEN
        @new_ticket.last_action = State::NONE
        @new_ticket.requestor_username = get_current_username()
          
        if (@new_ticket.save!)
          email_new_ticket(@new_ticket, user)                  
          flash[:notice] = "Request created."
          redirect_to(:action => :new)      
        end      
      end
    rescue Exception => ex
      logger.error(ex)
      flash[:notice] = ex.to_s
      redirect_to(:action => :new)
    end
    
  end
  
  def open()
    begin
      condition = "state = '#{State::OPEN}'" 
      @open_tickets = Ticket.find(:all, :conditions => condition)
    rescue Exception => ex
      logger.error(ex)
    end
  end
  
  def find(id)
    Ticket.find(id)
  end
  
  #-----------------------------------------------------------------------------  
  private
  
  def email_new_ticket(ticket, user)
    TicketMailer.send_new_ticket(ticket, user)
  end
  
  def email_completed_ticket(ticket, user)
    TicketMailer.send_completed_ticket(ticket, user)
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
  
end
