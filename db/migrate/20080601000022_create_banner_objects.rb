require "migration_helpers"

class CreateBannerObjects < ActiveRecord::Migration 
  extend MigrationHelpers 

  def self.up()
    create_table :banner_objects, :id => true do |t|
      t.column :description,          :string,  :null => false
      t.column :type_id ,             :integer, :null => false
    end
    foreign_key(:banner_objects, :type_id, :banner_object_types)
  end

  def self.down
    drop_table(:banner_objects)
  end  
end
