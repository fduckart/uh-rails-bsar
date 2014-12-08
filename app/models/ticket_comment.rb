class TicketComment < ActiveRecord::Base
  belongs_to :ticket
  
  def to_s
    "TicketComment [id = #{id}; ticket_id = #{:ticket_id}; comment = '#{comment}]"
  end
end