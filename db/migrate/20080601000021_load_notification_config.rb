class LoadNotificationConfig < ActiveRecord::Migration 
  def self.up
      n1 = NotificationsHelper::NotificationConfig.new
      n1.save!
  end
end