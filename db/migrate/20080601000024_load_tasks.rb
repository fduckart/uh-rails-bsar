require 'migration_helpers'

class LoadTasks  < ActiveRecord::Migration
  extend MigrationHelpers 
  def self.up()
    load_records_from_fixture('tasks')
  end
end
