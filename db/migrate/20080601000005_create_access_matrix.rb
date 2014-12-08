require 'migration_helpers'
require 'controller_actions'

class CreateAccessMatrix  < ActiveRecord::Migration
  extend MigrationHelpers
  
  def self.up()
    create_table :access_matrix, :id => true, :force => true do |t|
      t.column :role_id,     :integer, :null => false      
      t.column :controller,  :string,  :null => false
      t.column :method,      :string,  :null => false
      t.column :allowed,     :boolean, :null => false
    end
   
    foreign_key(:access_matrix, :role_id, :roles)
    
    load_data()
  end
 
  def self.down()
    drop_table(:access_matrix)
  end
  
  #-----------------------------------------------------------------------------
  private

  def self.load_data()
    # 1 = Banner User.
    # 2 = Requestor.
    # 3 = Coordinator.
    # 4 = Approver.
    # 5 = Manager.
    
    truths = {
      1 => {'login'     => ControllerActions::BANNERITE_LOGIN}, 
      2 => {'login'     => ControllerActions::REQUESTOR_LOGIN,
            'terminate' => ControllerActions::REQUESTOR_TERMINATE,
            'ticket'    => ControllerActions::REQUESTOR_TICKET},
      3 => {'login'     => ControllerActions::COORDINATOR_LOGIN,
            'terminate' => ControllerActions::COORDINATOR_TERMINATE,
             'ticket'   => ControllerActions::COORDINATOR_TICKET},
      4 => {'login'     => ControllerActions::APPROVER_LOGIN,
            'terminate' => ControllerActions::APPROVER_TERMINATE,
            'ticket'    => ControllerActions::APPROVER_TICKET},
      5 => {'login'     => ControllerActions::MANAGER_LOGIN,
            'terminate' => ControllerActions::MANAGER_TERMINATE,
            'ticket'    => ControllerActions::MANAGER_TICKET}
    }
    

    
    directory = File.join(File.dirname(__FILE__)) + '/../../test/fixtures'
    file = File.new("#{directory}/access_matrix.yml", "w")
    
    # Put some necessary comments at the top of the file.
    file.write("# Important Note:\n")
    file.write("# This file is generated from a script.\n")
    file.write("# Direct edits to this file may be overwritten.\n\n")
    
    i = 1
    for c in truths.keys
      cs = truths[c].keys
      for k in cs
        for v in truths[c][k]
          file.write("id_#{i}:\n")
          file.write("  id: #{i}\n")
          file.write("  role_id: #{c}\n")
          file.write("  controller: #{k}\n")
          file.write("  method: #{v}\n")
          file.write("  allowed: true\n")
          file.write("\n")
          
          i += 1
        end
      end
    end    

    file.close()

    # Now load the fixture into the main DB.
    load_records_from_fixture('access_matrix')
  end
end
