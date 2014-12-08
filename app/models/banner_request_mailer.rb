class BannerRequestMailer < ActionMailer::Base
  
  BIM_EMAIL = EmailAddresses::BIM
  REGISTRAR_EMAIL = EmailAddresses::REGISTRAR
  
  def self.send_ticket(ticket,user) 
    return self.deliver_email(ticket,user)
  end
  
  
  def email(ticket,user)
    @subject = 'Request to'
    @subject += ' Terminate' if ticket.task_id==2 
    @subject += ' Create' if ticket.task_id==1 
    @subject += ' Modify' if ticket.task_id==6 
    @subject += ' Reset Password for' if ticket.task_id==3 
    @subject += ' Banner Account'
    @subject = "Completed - " + @subject if ticket.state =='complete'
    
    @body['ticket'] = ticket
    @body['user'] = user
    ticket.state == 'complete' ? @recipients = REGISTRAR_EMAIL : @recipients = BIM_EMAIL
    @from         = BIM_EMAIL
    @sent_on      = Time.now
    headers("Reply-to" => "#{BIM_EMAIL}")
  end
end
