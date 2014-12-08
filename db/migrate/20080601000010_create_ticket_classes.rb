class CreateTicketClasses < ActiveRecord::Migration 
  
  def self.up
    create_table :ticket_classes, :id => true, :force => true do |t|
      t.column :name,                 :string,  :null => false
      t.column :ticket_id,      :integer, :null => false
      t.column :class_type_id,        :integer, :null => false, :default => 1
    end        
    
    add_index :ticket_classes, [:name, :ticket_id], :unique => true    
  end

  def self.down
    drop_table :ticket_classes
  end
  
end
