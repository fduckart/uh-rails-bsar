class Bannerite < Role  

  validates_inclusion_of     :is_system_role, 
    {:in => [false], :message => "can only be set to false."}

end
