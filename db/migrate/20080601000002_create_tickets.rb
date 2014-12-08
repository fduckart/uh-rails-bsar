require "application_helper"

class CreateTickets < ActiveRecord::Migration
  include ApplicationHelper
  
  def self.up
    create_table :tickets do |t|
      t.column :username,        :string,     :null => false
      t.column :requestor_username, :string,  :null => false
      t.column :copy_username,   :string
      t.column :task_id,         :integer,    :null => false, :default => 1
      t.column :state,           :string,     :null => false, :default => State::OPEN
      t.column :description,     :string,     :null => true
      t.column :permissions,     :string,     :null => true   
      t.column :date,            :datetime,   :null => false
      t.column :last_action,     :string
      t.column :is_urgent,       :boolean,    :null => false, :default => 1
      t.column :reason,          :integer,    :null => true
      t.column :close_task_id,   :integer,    :null => true
      t.column :is_listserv_done,:boolean,    :null => true
    end
  end

  def self.down
    drop_table :tickets
  end
end
