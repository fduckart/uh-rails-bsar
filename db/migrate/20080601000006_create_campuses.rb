class CreateCampuses < ActiveRecord::Migration
  def self.up
    create_table :campuses do |t|
      t.column :code,            :string, :null => false, :limit => 3
      t.column :description,     :string, :null => false
    end        
    add_index :campuses, :code, :unique => true    
  end

  def self.down
    drop_table :campuses
  end
end
