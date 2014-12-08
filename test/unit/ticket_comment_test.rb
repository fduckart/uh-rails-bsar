require File.dirname(__FILE__) + '/../test_helper'

class TicketClassTest < Test::Unit::TestCase
  fixtures :users
  fixtures :roles
  fixtures :tickets
  fixtures :ticket_comments
  
  def setup
    @user = users(:requestor)
    assert @user.is_system_user?
  end
  
  def test_add_comments    
    br = Ticket.find(:first)
    ticket_comment_count = br.ticket_comments.size 
    comment_count = TicketComment.find(:all).size 

    rc = TicketComment.new
    rc.ticket_id = br.id
    rc.comment = 'You Can Go Your Own Way'
    rc.date = Time.now
    rc.user_id = @user.id
    rc.user_role_id = @user.role.id
    rc.save!
    assert_equal comment_count + 1, TicketComment.find(:all).size 
    
    br.ticket_comments << rc
    br.save!    
    assert_equal ticket_comment_count + 1, br.ticket_comments.size 
    
    rc2 = TicketComment.new
    rc2.ticket_id = br.id
    rc2.comment = 'I can still hear you saying you would never break the chain.'
    rc2.date = Time.now
    rc2.user_id = @user.id
    rc2.user_role_id = @user.role.id
    rc2.save!
    br.ticket_comments << rc2
    br.save!
    
    assert_equal ticket_comment_count + 2, br.ticket_comments.size 
  end
  
end
