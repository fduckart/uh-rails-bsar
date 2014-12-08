class FerpaMailer < ActionMailer::Base

  def notice(user)
    @subject    = 'FERPA Notice'
    @body       = {}
    @recipients = ['fduckart@hotmail.com', user.email]
    @from       = 'duckart@hawaii.edu'
    @sent_on    = Time.now
#    headers         "Reply-to" => "#{user.email}"
  end
 
  def reminder(user)
    @subject    = 'FERPA Reminder'
    @body       = {}
    @recipients = ['fduckart@hotmail.com', user.email]
    @from       = 'duckart@hawaii.edu'
    @sent_on    = Time.now
#    headers         "Reply-to" => "#{user.email}"
  end
  
end
