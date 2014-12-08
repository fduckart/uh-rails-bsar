class CreateFormAccessTypes < ActiveRecord::Migration 
  
  def self.up
    create_table :form_access_types, :id => true do |t|
      t.column :code,                 :string, :limit => 1, :null => false 
      t.column :description,          :string, :null => false
    end        
    
    add_index :form_access_types, [:code], :unique => true
  end

  def self.down
    drop_table :form_access_types
  end
  
end
