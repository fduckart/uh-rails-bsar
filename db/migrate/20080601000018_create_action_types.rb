class CreateActionTypes < ActiveRecord::Migration 
  def self.up
    create_table :action_types, :id => true do |t|
      t.column :description,          :string, :null => false
    end
  end

  def self.down
    drop_table :action_types
  end  
end
