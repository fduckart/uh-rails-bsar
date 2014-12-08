class LoadFormAccessTypes  < ActiveRecord::Migration 
  def self.up
    query = FormAccessType.new(:code => 'Q', :description => 'Query')
    query.save!

    modify = FormAccessType.new(:code => 'M', :description => 'Modify')
    modify.save!
  end
end
