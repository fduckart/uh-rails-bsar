class Ticket < ActiveRecord::Base
  
  STATES = [
    # Displayed             Stored in DB.
    [ 'none',               'none'     ],
    [ 'Open',               'open'     ], 
    [ 'Complete',           'complete' ]
  ]
  
  has_many :ticket_campuses
  has_many :campuses, :through => :ticket_campuses
  has_many :ticket_classes
  has_many :ticket_comments
  
  belongs_to  :task
  
  validates_presence_of :task
  validates_presence_of :username
  validates_presence_of :requestor_username
  validates_presence_of :date
  validates_presence_of :state
  validates_inclusion_of :state, :in => STATES.map {|disp, value| value}
  
  def add_campus(campus)
    self.ticket_campuses.build(:campus_id => campus.id)
  end
  
  def add_campus_ids=(ids)
    if (!ids.nil?)
      for id in ids
        campus = Campus.find(id)
        add_campus(campus)
      end
    end
  end
  
  def has_campus?(campus)
    # Null guard.
    if campus.nil?
      return false
    end
    
    for tc in self.ticket_campuses
      if (tc.campus_id == campus.id)
        return true
      end
    end
    
    return false
  end
  
  def remove_campus(campus)
    self.campuses.delete(campus)
  end
  
  def before_validation()
    self.username = trim(self.username)
    self.requestor_username = trim(self.requestor_username)
    self.state = trim(self.state)
  end
  
  def self.closed_counter()
    sql='SELECT'
    sql += ' date_format(date,"%b %Y") as month_year,'
    sql += ' (select count(*) from tickets ter where ter.task_id=2 and ter.state= \'complete\' and date_format(t.date,"%b %Y")=date_format(ter.date,"%b %Y")) as terminate_requests,'
    sql += ' (select count(*) from tickets ter where ter.task_id =1 and ter.state= \'complete\' and date_format(t.date,"%b %Y")=date_format(ter.date,"%b %Y")) as new_requests, '
    sql += ' (select count(*) from tickets ter where ter.task_id = 6 and ter.state= \'complete\' and date_format(t.date,"%b %Y")=date_format(ter.date,"%b %Y")) as modify_requests'
    sql += ' from tickets t'
    sql += ' GROUP BY date_format(date,"%b %Y")'
    sql += ' ORDER BY date DESC '
   
    self.find_by_sql(sql)
  end
  
  def requestor_email()
    return self.requestor_username + '@hawaii.edu'
  end
  
  def to_s()
    s = 'Ticket ['
    s += 'id = ' + self.id.to_s + '; '
    s += 'description = ' + self.description.to_s + '; '
    s += 'state = ' + self.state.to_s + '; '
    s += 'username = ' + self.username.to_s + '; '
    s += 'date = ' + self.date.to_s 
    s += '; reason = ' + self.reason.to_s if self.reason 
    s += '; remove_state = ' + self.close_task_id.to_s if self.close_task_id
    s += ']'
    
    return s
  end
  
  def validate()
    campus_duplicate_check
  end
  
  # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  private
  
  def campus_duplicate_check()
    campus_ids = Hash.new
    for rc in self.ticket_campuses
      id_str = rc.campus_id.to_s 
      if campus_ids.has_key?(id_str)
        msg = "Duplicate Campus ID: " + id_str
        raise DuplicateTicketCampusException.new(msg)
      end
      campus_ids[id_str] = true
    end
  end
  
  def trim(value)
    if value
      value = value.strip
    end
    return value
  end
end
