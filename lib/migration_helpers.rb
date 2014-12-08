module MigrationHelpers

  def foreign_key(from_table, from_column, to_table, suffix = nil)
    constraint_name = "fk_#{from_table}_#{to_table}"
    if (!suffix.nil?)
      constraint_name += "_#{suffix}"
    end
    
    execute %{alter table #{from_table}
              add constraint #{constraint_name}
              foreign key (#{from_column})
              references #{to_table}(id)}
  end
  
  def drop_foreign_key(from_table, to_table, suffix = nil)
    constraint_name = "fk_#{from_table}_#{to_table}"
    if (!suffix.nil?)
      constraint_name += "_#{suffix}"
    end
        
    execute %{ALTER TABLE #{from_table} 
              DROP FOREIGN KEY #{constraint_name}}              
  end
  
  def load_records_from_fixture(name, path = File.join('..', 'test', 'fixtures'))
    path = path.strip if path
    sep = File::SEPARATOR
    path = (path + sep) if !path.index(/#{sep}$/)
    path = (sep + path) if !path.index(/^#{sep}/)
    directory = File.join(File.dirname(__FILE__), path)
    Fixtures.create_fixtures(directory, name)    
  end
end
