class TerminateMailer < ActionMailer::Base

  BIM_EMAIL = EmailAddresses::BIM
  REGISTRAR_EMAIL = EmailAddresses::REGISTRAR
  
  def self.send_new_ticket(ticket, user) 
    return self.deliver_new_ticket(ticket, user)
  end

  def self.send_completed_ticket(ticket, user)
    return self.deliver_completed_ticket(ticket, user)
  end
  
  def new_ticket(ticket, user)
    @subject      = 'Request to ' + ticket.task.description.chop()    
    @body['ticket'] = ticket
    @body['user'] = user
    @recipients   = [BIM_EMAIL]
    @from         = BIM_EMAIL
    @sent_on      = Time.now
    headers("Reply-to" => "#{BIM_EMAIL}")
  end
  
  def completed_ticket(ticket, user)
    @subject = 'Completed ' + ticket.task.description.chop()
    @body['ticket'] = ticket
    @body['user'] = user
    @recipients = [REGISTRAR_EMAIL, ticket.requestor_email()]
    @from = BIM_EMAIL
    @sent_on = Time.now
    headers("Reply-to" => "#{BIM_EMAIL}")
  end
end
