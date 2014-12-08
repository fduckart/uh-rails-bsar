class Approver < Role 
  
  validates_inclusion_of     :is_system_role, 
    {:in => [true], :message => "can only be set to false."}

end
