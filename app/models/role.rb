class Role < ActiveRecord::Base
  
  validates_presence_of    :name
  validates_uniqueness_of  :name
  
  attr_readonly :is_system_role
  
  def self.find_system_roles(symbol = :all)
    return self.find(symbol, :conditions => 'is_system_role = true')
  end
  
  def to_s
    "#{type} [id = #{id}; name = #{name}; type = #{type}; #{is_system_role}]"    
  end  
end
