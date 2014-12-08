class TicketCampus < ActiveRecord::Base
  belongs_to :ticket
  belongs_to :campus

  def get_campus_id
    return campus_id
  end
  
  def to_s
    s = "TicketCampus [campus_id = #{campus_id}; "
    s += "ticket_id = #{ticket_id}]"
    return s
  end
  
end