class AccessMatrix < ActiveRecord::Base
  set_table_name :access_matrix
  
  def to_s
    s = "AccessMatrix [id = #{id}; allowed = #{allowed}; role_id = #{role_id}; "
    s += "controller = #{controller}; method = #{method}]"
    
    return s
  end
end
