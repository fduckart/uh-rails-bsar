class Task < ActiveRecord::Base

  has_many :tickets
  validates_presence_of :name
  validates_presence_of :description
  
  def to_s
    "Task [id = #{id}; name = #{name}, description = #{description}]"
  end
end
