require File.dirname(__FILE__) + '/../test_helper'
require 'terminate_mailer'

class TerminateMailerTest < Test::Unit::TestCase

  fixtures :tickets
  fixtures :reasons
  
  def setup
    @ticket = tickets(:three)
    
    # Since we are doing a 'unit' test here, override the
    # LDAP lookup method so we don't hit the actual server.
    def @ticket.get_user()
      p = Person.new
      p.uid = self.username
      p.email = self.username + '@hawaii.edu'
      p.display_name = self.username
      
      return p    
    end    
  end

  def test_new_ticket()
    email =  TerminateMailer.deliver_new_ticket(@ticket, @ticket.get_user)
    task_description = @ticket.task.description.chop()
    assert_equal('Request to ' + task_description, email.subject)
    assert_equal(EmailAddresses::BIM, email.to[0])

    username_line = 'UH Username: ' + @ticket.username
    assert_match(/#{username_line}/,  email.body)
    
    reason_text = Reason.find(@ticket.reason).description
    assert_match(/#{reason_text}/,  email.body)
    
    url = ENV['BAS_URL'] + '/terminate/edit/' + @ticket.id.to_s
    assert_match(/#{url}/, email.body)

    ticket_comments = @ticket.description
    assert_match(/#{ticket_comments}/, email.body)
  end

  def test_completed_ticket()
    @ticket.description += "\nAll done."
    task_description = @ticket.task.description.chop()
    
    email =  TerminateMailer.deliver_completed_ticket(@ticket, @ticket.get_user)
    assert_equal('Completed ' + task_description, email.subject)
    assert_equal(@ticket.requestor_email(), email.to[0])

    username_line = 'UH Username: ' + @ticket.username
    assert_match(/#{username_line}/,  email.body)
    
    ticket_comments = @ticket.description
    assert_match(/#{ticket_comments}/, email.body)    
    assert_match(/All done/, email.body)
  end
end
