class CreateBannerObjectTypes < ActiveRecord::Migration 

  def self.up
    create_table :banner_object_types, :id => true do |t|
      t.column :description,          :string, :null => false
    end
  end

  def self.down
    drop_table :banner_object_types
  end  
end

