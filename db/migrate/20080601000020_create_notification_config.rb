class CreateNotificationConfig < ActiveRecord::Migration 
  def self.up
    create_table :notification_configs, :id => true do |t|
      t.column :last_run_date,        :datetime, :null => true
      t.column :email_batch_size,     :integer,  :null => false, :default => 100
      t.column :first_reminder_days,  :integer,  :null => false, :default => 7
      t.column :second_reminder_days, :integer,  :null => false, :default => 8
    end
  end

  def self.down
    drop_table :notification_configs
  end
  
end

