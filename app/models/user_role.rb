class UserRole < Role
  
  validates_inclusion_of     :is_system_role, 
    {:in => [false], :message => "can only be set to false."}

  def initialize(attributes = nil)
    if attributes.nil?
      attributes = Hash.new
    end
    attributes[:is_system_role] = false
    super(attributes)
  end
  
  def to_s
    "UserRole [id = #{id}; name = #{name}; type = #{type}; #{is_system_role}]"    
  end
end
