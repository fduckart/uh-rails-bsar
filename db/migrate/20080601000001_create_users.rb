class CreateUsers < ActiveRecord::Migration
  
  COORDINATOR = 3
  
  def self.up
    create_table :users, :id => true, :force => false do |t|
      t.column :username, :string,  :null => false
      t.column :role_id,  :integer, :null => false, :default => COORDINATOR
    end        
    
    add_index :users, [:username], :unique => true 
  end

  def self.down
    drop_table :users

    # Some random clean ups used during development.
    # Remove this section later.
    drop_table_ex :access_types
    drop_table_ex :access_matrix
    drop_table_ex :action_types
    drop_table_ex :banner_object_types
    drop_table_ex :tasks
    drop_table_ex :tickets
    drop_table_ex :notification_configs
    drop_table_ex :reasons
    drop_table_ex :ticket_comments
    drop_table_ex :roles
    drop_table_ex :system_roles
    drop_table_ex :system_users_roles
    drop_table_ex :users
    drop_table_ex :users_roles   
  end
  
  
  #-----------------------------------------------------------------------------
  private
  def self.drop_table_ex(name)
    begin
      drop_table name
    rescue Exception 
      # Ignored. 
    end
  end
  
end
