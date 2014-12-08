class Person
  attr_accessor :firstname
  attr_accessor :lastname
  attr_accessor :uhuuid
  attr_accessor :uid
  attr_accessor :email
  attr_accessor :phone
  attr_accessor :title
  attr_accessor :department 
  attr_accessor :system
  attr_accessor :display_name
  
  def to_s
    s = "Person [uhuuid = #{uhuuid}; uid = #{uid}; "
    s += "firstname = #{firstname}; lastname = #{lastname}; "
    s += "display_name = #{display_name}; "
    s += "email = #{email}]"
    return s
  end
end
