class UserRoleMap < ActiveRecord::Base
  belongs_to :user
  belongs_to :role
  
  # -> Method returns UserRoleMap object which match the role and city passed to it.
  def self.userRoleByCity(role_id,city_id)
   return UserRoleMap.where("role_id = ? and user_id IN (SELECT id FROM users WHERE city_id = ? and is_deleted=0)",role_id,city_id)
  end
  
  # -> Method returns UserRoleMap object which match the role passed to it.
  def self.userRoleMap(role_id)
   return UserRoleMap.where("role_id = ? and user_id IN (SELECT id FROM users WHERE is_deleted=0)",role_id)
  end
  
  # -> Method returns UserRoleMap object which match the user id passed to it.
  def self.getRoleidByUserid(user_id)
    return UserRoleMap.select("role_id").where(:user_id => user_id)
  end

  # -> Method returns the roles which a certain user has, by the id passed to it.
  def self.getRolesByUserid(user_id)
    role_for_user = UserRoleMap.getRoleidByUserid(user_id)
    roles = Array.new
    role_for_user.each do |urmap|
      roles.push(Role.find(urmap.role_id))
    end

    return roles
  end
end
