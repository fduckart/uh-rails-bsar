require File.dirname(__FILE__) + '/../test_helper'

class TicketClassTest < Test::Unit::TestCase
  fixtures :tickets
  fixtures :ticket_classes
  
  def test_add_right    
    br = Ticket.find(:first)
    rights_count = br.ticket_classes.size
    
    br.ticket_classes << TicketClass.new(:ticket => br, :name => 'I am')
    br.save!   
    assert_equal rights_count + 1, br.ticket_classes.size
    
    rc = TicketClass.new
    rc.ticket = br
    rc.name = 'One more lifetime'
    br.ticket_classes << rc
    br.save!
    assert_equal rights_count + 2, br.ticket_classes.size
  end
  
end
