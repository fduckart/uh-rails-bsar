class LoadBannerObjectTypes < ActiveRecord::Migration 
  def self.up
    bo1 = BannerObjectType.new
    bo1.description = 'Form'
    bo1.save!
    
    bo2 = BannerObjectType.new
    bo2.description = 'Class'
    bo2.save!
  end
end
