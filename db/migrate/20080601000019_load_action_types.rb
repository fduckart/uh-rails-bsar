class LoadActionTypes < ActiveRecord::Migration 
  def self.up
    descriptions = %w[Approve Cancel Create Deny Delete Modify]
    descriptions.each do |d|
      at = ActionType.new
      at.description = d
      at.save!
    end
  end
end
