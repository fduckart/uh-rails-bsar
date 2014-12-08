require 'migration_helpers'

class CreateRoles < ActiveRecord::Migration
  extend MigrationHelpers
  
  def self.up
    create_table :roles, :force => true do |t|
      t.column :type, :string,            :null => false
      t.column :name, :string
      t.column :rank, :integer,           :null => false, :default => 10
      t.column :is_system_role, :boolean, :null => false, :default => false 
      t.column :home, :string,            :null => false, :default => 'index'
    end
    foreign_key(:users, :role_id, :roles)

    # Create join table for Roles and Users.
    create_table :users_roles, :id => false do |t|
      t.column :user_id,     :integer, :null => false
      t.column :role_id,     :integer, :null => false      
    end
    
    add_index :users_roles, [:user_id, :role_id], :unique => true
    foreign_key(:users_roles, :user_id, :users)
    foreign_key(:users_roles, :role_id, :roles)

    
    load_records_from_fixture('roles')
    
    # Check on the necessary role values.
    r1 = Bannerite.find(1)
    check_role(r1, 1, 'banner_user')
    check_home(r1, 1, 'index')
    
    r2 = Requestor.find(2)
    check_role(r2, 2, 'requestor')
    check_home(r2, 2, 'index')
    
    r3 = Coordinator.find(3)
    check_role(r3, 3, 'coordinator')
    check_home(r3, 3, 'index')
    
    r4 = Approver.find(4)
    check_role(r4, 4, 'approver')
    check_home(r4, 4, 'index')
    
    r5 = Manager.find(5)
    check_role(r5, 5, 'manager')
    check_home(r5, 5, 'index')
  end

  def self.down
    execute "alter table users drop foreign key fk_users_roles"
    execute "delete from roles"
    drop_table :users_roles 
    drop_table :roles
  end
  
  # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  private
  
  def self.check_role(r, id, name)
    if r.id != id or r.name != name
      down  # Clean up this migration attempt.
      raise "Role was not created correctly.  role: " + r.to_s
    end
  end
  
  def self.check_home(r, id, home)
    if r.id != id or r.home != home
      down  # Clean up this migration attempt.
      raise "Role was not created correctly.  role: " + r.to_s
    end
  end
  
end
