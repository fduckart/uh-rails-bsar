class LoadTicketClasses  < ActiveRecord::Migration 
  def self.up
    rc = TicketClass.new
    rc.ticket_id
    rc.class_type_id
  end
end
