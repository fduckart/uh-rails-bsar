class User < ActiveRecord::Base
  
  validates_presence_of     :username
  validates_uniqueness_of   :username
  
  belongs_to                :role
  validates_presence_of     :role
  
  def self.authenticate(name)
    return self.find_by_username(name)
  end
  
  def is_system_user?
    if role.nil?
      return false
    end
    return role.is_system_role
  end
    
  def to_s
    s = "User [id = #{id}; username = #{username}"
    if self.role != nil
      s += "; role = " + self.role.name  
    end
    s += "; is_system_user = #{self.is_system_user?}"
    s += "]"
    
    return s
  end
  
end
