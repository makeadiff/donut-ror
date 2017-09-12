class ReportsTo < ActiveRecord::Base
  belongs_to :user
  belongs_to :manager ,:class_name => 'User'

  # -> Method returns the manager id of the user id which is
  #    passed to the method.
  def self.getManageridByUserid(user_id)
    return ReportsTo.select("manager_id").where(:user_id=> user_id)
  end
end
