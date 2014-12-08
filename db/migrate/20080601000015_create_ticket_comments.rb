require "migration_helpers"

class CreateTicketComments < ActiveRecord::Migration 
  extend MigrationHelpers 
  
  def self.up()
    create_table :ticket_comments do |t|
      t.column :ticket_id,      :integer,  :null => false
      t.column :user_id,              :integer,  :null => false
      t.column :user_role_id,         :integer,  :null => false
      t.column :date,                 :datetime, :null => false
      t.column :comment,              :string,   :null => false, :limit => 2000 
    end        
    
    foreign_key(:ticket_comments, :ticket_id, :tickets)
    foreign_key(:ticket_comments, :user_id, :users)
    foreign_key(:ticket_comments, :user_role_id, :roles)
  end

  def self.down()
    drop_table(:ticket_comments)
  end
  
end
