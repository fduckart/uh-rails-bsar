require File.expand_path(File.dirname(__FILE__) + "/../../config/environment")

class DemoDataLoader 
  include ApplicationHelper
  NAMES = ['duckart', 'jgeiss', 'cahana', 'kimotor']

  def run() 
    remove_task = Task.find(TaskType::REMOVE_ACCOUNT)
  
    # Load some test 'closed' termination tickets.
    now = Time.now    
    for i in 1..60
      ticket = Ticket.new
      ticket.task = remove_task
      ticket.requestor_username = 'terminator'
      ticket.username = NAMES[i % NAMES.size]
      ticket.description = 'Terminator ' + i.to_s
      ticket.date = now
      ticket.state = State::COMPLETE
      ticket.last_action = State::OPEN
      ticket.is_urgent = false
      ticket.reason = i % 4
    
      ticket.save! 
      now -= (60 * 60 * 24)
    end
    
     # Load some test 'open' termination tickets.
    now = Time.now
    for i in 1..3
      ticket = Ticket.new
      ticket.task = remove_task
      ticket.requestor_username = 'terminator'
      ticket.username = NAMES[i % NAMES.size]
      ticket.description = 'New Termination request ' + i.to_s + '.'
      ticket.date = now
      ticket.state = State::OPEN
      ticket.last_action = State::NONE
      ticket.is_urgent = false
      ticket.reason = i % 4
              
      ticket.save! 
      now -= 5
    end
  end
end

ddl = DemoDataLoader.new
ddl.run()
