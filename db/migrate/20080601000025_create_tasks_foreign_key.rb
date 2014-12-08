require "migration_helpers"

class CreateTasksForeignKey < ActiveRecord::Migration
  extend MigrationHelpers 
  
  def self.up()
    foreign_key(:tickets, :task_id, :tasks, 'a')
    foreign_key(:tickets, :close_task_id, :tasks, 'b')
  end
  
  def self.down()
    drop_foreign_key(:tickets, :tasks, 'b')
    drop_foreign_key(:tickets, :tasks, 'a')
  end
end
