class Campus < ActiveRecord::Base
     
  has_many :ticket_campuses
  
  validates_presence_of    :code
  validates_uniqueness_of  :code
  
  def to_s
    "Campus [id = #{id}; code = #{code}; description = #{description}]"    
  end
end
