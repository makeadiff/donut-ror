class RoleReportTo < ActiveRecord::Base
  belongs_to :role, :foreign_key => 'user_role_id'
  belongs_to :manager_role ,  :class_name => 'Role'
  
  # -> Method returns the id of the user assigned to the 
  #    manager id passed to it.
  def self.getUserRoleidByManagerRoleid(manager_roleid)
    return RoleReportTo.select("user_role_id").where(:manager_role_id => manager_roleid)
  end

end
