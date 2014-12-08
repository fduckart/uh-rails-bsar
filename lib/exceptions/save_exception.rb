class SaveException < StandardError  
  def initialize(msg = nil)
    super(msg)
  end
end