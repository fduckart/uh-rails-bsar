class CreateFerpas < ActiveRecord::Migration
  def self.up
    create_table :ferpas, :id => true do |t|
      t.column :user_id,            :integer, :null => false
      t.column :ferpa_sent_date,    :datetime
      t.column :ferpa_sent_count,   :integer 
      t.column :ferpa_action_date,  :datetime 
      t.column :ferpa_is_approved,  :boolean 
    end
  end

  def self.down
    drop_table :ferpas
  end
end
