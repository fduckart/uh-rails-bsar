require 'migration_helpers'
require 'active_record/fixtures'

class LoadUsers < ActiveRecord::Migration
  extend MigrationHelpers
  def self.up
    load_records_from_fixture('users', '../db/data')    
  end
end
