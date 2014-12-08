require 'migration_helpers'
require 'active_record/fixtures'

class CreateReasons < ActiveRecord::Migration
  extend MigrationHelpers 
  
  def self.up()
    create_table :reasons, :id => true do |t|
      t.column :description,  :string, :null => false
    end
    
    load_records_from_fixture('reasons')
  end

  def self.down()
    drop_table :reasons
  end
end
