require File.expand_path(File.dirname(__FILE__) + "/../../config/environment")
require 'migration_helpers'
require 'active_record/fixtures'

class RealDataLoader 
  include MigrationHelpers
  
  def run() 
    begin
      load_records_from_fixture('users', '../db/data')
#      load_records_from_fixture('tasks')
#      load_records_from_fixture('roles')
#      load_records_from_fixture('access_matrix')
#      load_records_from_fixture('campuses')
#      load_records_from_fixture('banner_object_types')

    rescue Exception => ex
      puts self.class.name + '; Exception: ' + ex.to_s()
    end
  end
end

# Run the loader.
rdl = RealDataLoader.new
rdl.run()
