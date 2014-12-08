class TicketClass < ActiveRecord::Base
  belongs_to :ticket
  
  def to_s
    "TicketClass [id = #{id}; name = #{name}; ticket_id = #{ticket_id}]"
  end
end