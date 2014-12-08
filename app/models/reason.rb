class Reason < ActiveRecord::Base
  def to_s
    "Reason [id = #{id}; description = #{description}]"
  end
end
