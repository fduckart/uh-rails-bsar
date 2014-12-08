class EmptyUser 
  def initialize(uh_uid = not_found())
    @uid = uh_uid || not_found()
  end  
  def display_name
    return not_found()
  end
  def uid
    return @uid
  end
  def username
    return not_found()
  end
  def uhuuid
    return not_found()
  end
  def is_system_user?
    return false
  end
  def email
    return not_found()
  end
  
  #-----------------------------------------------------------------------------
  private
  
  def not_found()
    return "Not found."
  end
end