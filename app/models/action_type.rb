class ActionType < ActiveRecord::Base
  def to_s
    "ActionType [id = #{id}; description = #{description}]"
  end
end
