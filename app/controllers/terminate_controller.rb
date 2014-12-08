require 'exceptions/ldap_lookup_exception'

class TerminateController < ApplicationController
  
  layout "admin"
  before_filter :check_access_privileges    
  
  def new()
    begin
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
        
        # Guard to check if State is there.
        if Strings.is_nil_or_empty(@new_ticket.state)
          flash_notice(ERRORS['empty_state'])
          has_errors = true
        end
        
        # Guard to check if Reason is there.
        if @new_ticket.reason.nil?
          flash_notice(ERRORS['empty_reason'])
          has_errors = true
        end
        
        if has_errors
          return  # Exit now.                
        end
        
        @new_ticket.requestor_username = get_current_username()
        @new_ticket.task = Task.find(TaskType::REMOVE_ACCOUNT)
        
        if @new_ticket.save!  
          email_new_ticket(@new_ticket,user);                  
          flash[:notice] = "Termination Request created."
          redirect_to(:action => :new)        
        end
      end
    rescue Exception => ex
      puts ex
      logger.error(ex)
      flash[:notice] = ex.to_s
      redirect_to(:action => :new)
    end
  end
  
  def edit()
    begin
      id = params[:id].to_i
      conditions = ["id = ? and task_id = ?", id, TaskType::REMOVE_ACCOUNT]
      @edit_ticket = Ticket.find(:first, :conditions => conditions)
      if !@edit_ticket.nil?
        if request.post?
          begin
            close = close_clicked?(params)
            if (close)
              @edit_ticket.state = State::COMPLETE
            end
            
            if @edit_ticket.update_attributes(params[:edit_ticket])
              if (close)
                user = lookup_cas_user(@edit_ticket.username)
                email_completed_ticket(@edit_ticket, user)
              end
              flash[:notice] = 'Request was successfully updated.'
              redirect_to(:controller => 'ticket', :action => 'open')
            else
              render(:action => 'edit')
            end
          rescue Exception => ex
            puts ex
            logger.error(ex)
            flash[:notice] = ex.to_s
            redirect_to(:controller => 'ticket', :action => :open)
          end    
        end
    else
      raise exception
    end   
    rescue Exception => ex
      logger.error(ex)
      redirect_to(:controller => 'ticket', :action => :open)
    end
  end
  
  def search()
    begin
      @performed_search = false
      @has_search_results = false
      if (request.post?)
        username = params[:value].to_s
        user_condition = "username = '#{username}'"
        @search_tickets = Ticket.find(:all, :conditions => user_condition, 
                                      :order => 'date DESC')
        @has_search_results = @search_tickets.size > 0
        @performed_search = true
      end
    rescue Exception => ex
      logger.error(ex)
    end
  end
 
  def closed()
    begin   
      @closed_tickets = Ticket.closed_counter
    rescue Exception => ex
      logger.error(ex)
    end
  end
  
  #-----------------------------------------------------------------------------  
  private
  
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
  
  def email_new_ticket(ticket, user)
    begin
      TerminateMailer.send_new_ticket(ticket, user)
    rescue Exception => ex
      puts ex
      logger.error(ex)
    end
  end
  
  def email_completed_ticket(ticket, user)
    begin
      TerminateMailer.send_completed_ticket(ticket, user)
    rescue Exception => ex
      puts ex
      logger.error(ex)
    end
  end
  
end