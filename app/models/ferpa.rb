class Ferpa < ActiveRecord::Base
  
  def to_s
    "Ferpa [id = #{id}; user_id = #{user_id}; sent_date = #{ferpa_sent_date}]"
  end
end