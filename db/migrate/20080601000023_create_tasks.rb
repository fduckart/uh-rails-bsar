class CreateTasks < ActiveRecord::Migration
  def self.up
    create_table :tasks, :id => true do |t|
      t.column :name,         :string, :null => false
      t.column :description,  :string, :null => false
      t.column :nature,       :string, :null => false, :default => 'primary'
    end
  end

  def self.down
    drop_table :tasks
  end
end
