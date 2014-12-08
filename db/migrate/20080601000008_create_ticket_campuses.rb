require "migration_helpers"

class CreateTicketCampuses < ActiveRecord::Migration 
  extend MigrationHelpers 
  
  def self.up()
    create_table :ticket_campuses, :id => false, :force => true do |t|
      t.column :campus_id,            :integer, :null => false
      t.column :ticket_id,      :integer, :null => false
    end        
    
    add_index(:ticket_campuses, [:campus_id, :ticket_id], :unique => true)
    foreign_key(:ticket_campuses, :campus_id, :campuses)
    foreign_key(:ticket_campuses, :ticket_id, :tickets)
  end

  def self.down()
    drop_table(:ticket_campuses)
  end
  
end
