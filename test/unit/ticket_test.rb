require File.dirname(__FILE__) + '/../test_helper'

class TicketTest < Test::Unit::TestCase
  include ApplicationHelper
  
  fixtures :tickets
  fixtures :campuses
  fixtures :tasks
  
  def test_lookup
    r1 = Ticket.find(2)
    assert_equal 2, r1.id
    assert_equal State::OPEN, r1.state
    assert_equal 'We belong as two together', r1.description
  end
  
  def test_new
    ticket_count = Ticket.count
    t = Time.now
    create_account_task = Task.find(1)
    
    r1 = Ticket.new 
    
    r1.requestor_username = 'duckart'
    r1.username = 'jaimeyh'
    r1.state = State::OPEN
    r1.date = t
    r1.description = 'test me, 1, 2, 3'
    r1.task = create_account_task
    
    assert_equal State::OPEN, r1.state
    assert_not_nil r1.date 
    assert_equal t, r1.date

    # Save it now.
    r1.save!
    
    assert_equal ticket_count + 1, Ticket.count 
    assert_equal 'test me, 1, 2, 3', r1.description
    assert_equal State::OPEN, r1.state
    assert_not_nil r1.date 
    assert_equal t, r1.date
  end
  
  def test_new_modify
    ticket_count = Ticket.count
    t = Time.now
    modify_account_task = Task.find(6)
    
    r1 = Ticket.new 
    
    r1.requestor_username = 'duckart'
    r1.username = 'jaimeyh'
    r1.state = State::OPEN
    r1.date = t
    r1.description = 'test me, again'
    r1.task = modify_account_task
    
    assert_equal State::OPEN, r1.state
    assert_not_nil r1.date 
    assert_equal t, r1.date

    # Save it now.
    r1.save!
    
    assert_equal ticket_count + 1, Ticket.count 
    assert_equal 'test me, again', r1.description
    assert_equal State::OPEN, r1.state
    assert_not_nil r1.date 
    assert_equal t, r1.date
    assert_equal 6, r1.task.id
  end

  def test_save_existing_ticket
    ticket = Ticket.find(:first)
    ticket.state = State::OPEN
    assert ticket.save!
  end
  
  def test_add_campus
    campus_count = Campus.count 
    
    ticket = Ticket.new
    assert_equal 0, ticket.campuses.count
    
    for c in Campus.find(:all)
      ticket.add_campus(c)
    end

    ticket.requestor_username = 'duckart'
    ticket.username = 'jaimeyh'
    ticket.state = State::NONE
    ticket.date = Time.now
    ticket.save!
    
    assert_equal campus_count, ticket.campuses.count
    
    # Should be able to locate all the campuses just loaded.
    ticket.campuses.each do |campus|
      c = Campus.find(campus.id)
      assert_equal campus.id, c.id
      assert_equal campus.code, c.code
      assert_equal campus.description, c.description
    end
    
    assert_equal campus_count, ticket.campuses.count
  end    
  
  def test_remove_campus
    campus_count = Campus.count 
    t = Ticket.new
    assert_equal 0, t.campuses.count
    
    for c in Campus.find(:all)
      t.add_campus(c)
    end

    t.requestor_username = 'duckart'
    t.username = 'drexler'
    t.state = State::NONE
    t.date = Time.now
    t.save!

    assert_equal campus_count, t.campuses.count

    # Remove all those campuses added above.
    for c in Campus.find(:all)
      t.remove_campus(c)
    end

    t.save!
    assert_equal 0, t.campuses.count
    
    # Try removing a campus again.
    t.remove_campus(campuses(:manoa))
    t.save!
    
  end
  
  def test_add_duplicate_campus_to_new_ticket
    ticket = create_basic_ticket()
    
    ticket.add_campus(campuses(:hilo))
    ticket.save
    
    # Add Manoa in twice... should be a problem.
    ticket.add_campus(campuses(:manoa))    
    ticket.add_campus(campuses(:manoa))
   
    begin
      ticket.save!
      saved = true
    rescue Exception
      saved = false   # As expected.
    end

    if saved
      flunk("Should not have reached here. Ticket " + req.to_s)
    end
  end
  
  def test_add_duplicate_campus_to_existing_ticket
    ticket = Ticket.find(:first)
    
    # Add Manoa in twice... should be a problem.
    ticket.add_campus(campuses(:manoa))    
    ticket.add_campus(campuses(:manoa))
   
    begin
      ticket.save!
      saved = true
    rescue Exception
      saved = false   # As expected.
    end

    if saved
      flunk("Should not have reached here. Ticket: " + ticket.to_s)
    end
  end
  
  def test_set_nil_date_on_ticket
    ticket = Ticket.find(:first)
    ticket.date = nil
    
    begin
      saved = ticket.save!
    rescue ActiveRecord::RecordInvalid
      # Expected exception.
    rescue Exception => ex
      fail("Unexpected excption type: " + ex.class.name)
    ensure
      assert !saved, "Error: Ticket was saved with a nil date."
    end
  end
  
#  def test_illegal_nil_date_on_ticket
#    # Ticket with a bad date (null).  
#    # This the case of an bad database update using
#    # SQL command on the backend -- this shouldn't happen.
#    ticket = tickets(:baddate)
#    
#    begin
#      saved = ticket.save!
#    rescue ActiveRecord::RecordInvalid
#      # Expected exception.
#    rescue Exception => ex
#      fail("Unexpected exception type: " + ex.class.name)
#    ensure
#      assert !saved, "Error: Ticket was saved with a nil date."
#    end    
#  end
  
#  def test_set_date
#    now = Time.now
#    ticket = tickets(:baddate)
#    ticket.date = now
#    saved = ticket.save!
#    
#    assert saved
#    assert_equal now, ticket.date
#  end

  def test_has_campus
    ticket = create_basic_ticket()
    
    hilo = campuses(:hilo)
    ticket.add_campus(hilo)
    assert ticket.has_campus?(hilo)

    ticket.save!
    
    t = Ticket.find(ticket.id)
    assert t.has_campus?(hilo)
    
    maui = campuses(:maui)
    assert !t.has_campus?(maui)
  end

#  this function is commented out in the controller 
#  def test_get_user
#    ticket = Ticket.find(:first)
#    requestor = ticket.get_user()
#    assert_not_nil requestor
#    assert requestor.uid.length > 0
#    
#    finder = DummyPersonFinder.new()
#    person = finder.lookup_by_username(requestor.uid)
#    assert_not_nil person
#    assert_equal person.uid, requestor.uid
#  end
  
#  def test_get_user_missing
#    # This shouldn't happen because of database constraints.
#    # The requestor username will get some non-nil default value.
#    ticket = tickets(:missingrequestor)
#    assert_not_nil ticket
#    assert_equal '', ticket.requestor_username
#  end
  
  #-----------------------------------------------------------------------------
  private
  
  def create_basic_ticket()
    ticket = Ticket.new
    ticket.requestor_username = 'duckart'
    ticket.username = 'jaimeyh'
    ticket.description = 'Feel Like Crying'
    ticket.state = State::NONE
    ticket.date = Time.now
    
    return ticket
  end
end
