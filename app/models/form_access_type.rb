class FormAccessType < ActiveRecord::Base
     
  def to_s
    "FormAccessType [id = #{id}; code = #{code}; description = #{description}]"    
  end
end
