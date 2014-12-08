require File.dirname(__FILE__) + '/../test_helper'

class TicketCampusTest < Test::Unit::TestCase
  fixtures :campuses
  fixtures :tickets
  
  def test_save
    count = TicketCampus.count 
    campus = campuses(:manoa)
    req = tickets(:one)
    
    rc1 = TicketCampus.new
    rc1.campus_id = campus.id
    rc1.ticket_id = req.id     
    rc1.save!
    
    assert_equal count + 1, TicketCampus.count 
  end
  
  def test_save_many_campuses
    ticket = Ticket.new
        
    ticket.username = 'duckart'
    ticket.requestor_username = 'duckart'
    ticket.date = Time.now()
    assert ticket.save!
    assert_equal 0, ticket.campuses.count 
  
    ticket.add_campus(campuses(:manoa))
    ticket.add_campus(campuses(:hilo))
    ticket.add_campus(campuses(:hawaii))
    assert ticket.save!
    assert_equal 3, ticket.campuses.count
  end
  
  def test_save_many_campuses_by_id
    ticket = Ticket.new
        
    ticket.username = 'duckart'
    ticket.requestor_username = 'duckart'
    ticket.date = Time.now()
    assert ticket.save!
    assert_equal 0, ticket.campuses.count 
  
    ids = Array.new
    ids << campuses(:manoa).id
    ids << campuses(:kapiolani).id
    ids << campuses(:hilo).id
    ids << campuses(:hawaii).id
    
    ticket.add_campus_ids = ids 
    
    assert ticket.save!
    assert_equal 4, ticket.campuses.count
  end
  
end

