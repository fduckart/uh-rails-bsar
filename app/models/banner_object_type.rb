class BannerObjectType < ActiveRecord::Base
  def to_s
    "BannerObjectType [id = #{id}; description = #{description}]"
  end
end
