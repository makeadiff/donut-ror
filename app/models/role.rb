class Role < ActiveRecord::Base

  @ADMINISTRATOR = 'Admin'
  @CFR_FELLOW = 'FR Fellow'
  @NATIONAL_CFR_HEAD = 'National CFR Head'
  @CITY_PRESIDENT = 'City President'
  @EVENTS_FELLOW = 'Events Fellow'
  @NATIONAL_EVENTS_HEAD = 'National Events Head'
  @CFR_POC = 'CFR POC'
  @CITY_FINANCIAL_CONTROLLER = 'Finance Fellow'
  @NATIONAL_FINANCIAL_CONTROLLER = 'National Finance Fellow'
  @VOLUNTEER = 'Volunteer'

  has_many :role_report_tos ,foreign_key: 'user_role_id'
  has_many :manager_roles , :through => :role_report_tos

  has_many :inverse_role_reports_tos , :class_name => 'RoleReportTo' ,:foreign_key => 'manager_role_id'
  has_many :subordinate_roles , :through => :inverse_role_reports_tos ,:source => :user
  
  has_many :user_role_maps
  has_many :users, :through => :user_role_maps

  class << self
    attr_reader :ADMINISTRATOR,
                :CFR_FELLOW,
                :NATIONAL_CFR_HEAD,
                :CITY_PRESIDENT,
                :EVENTS_FELLOW,
                :NATIONAL_EVENTS_HEAD,
                :CFR_POC,
                :CITY_FINANCIAL_CONTROLLER,
                :NATIONAL_FINANCIAL_CONTROLLER,
                :VOLUNTEER
  end

  # -> Boolean method which returns true when the calling
  #    role object's role is national level, otherwise
  #    returns false.
  def has_no_managers?
    national_level_roles = [Role.ADMINISTRATOR,
                            Role.NATIONAL_CFR_HEAD,
                            Role.NATIONAL_FINANCIAL_CONTROLLER,
                            Role.NATIONAL_EVENTS_HEAD,
                            Role.CITY_PRESIDENT]
    national_level_roles.include?(self.role)
  end

  # -> Boolean method which returns true when the argument
  #    passed is a national level role, otherwise 
  #    returns false.
  def self.is_national_level_role?(role_name)
    national_level_roles = [Role.ADMINISTRATOR,
                            Role.NATIONAL_CFR_HEAD,
                            Role.NATIONAL_FINANCIAL_CONTROLLER,
                            Role.NATIONAL_EVENTS_HEAD]
    national_level_roles.include?(role_name)
  end

  # -> Boolean method which returns true when the calling
  #    role object's role is national level (as defined by
  #    the method), otherwise returns false.
  def has_no_selectable_managers?
    national_level_roles = [Role.ADMINISTRATOR,
                            Role.CFR_FELLOW,
                            Role.CITY_FINANCIAL_CONTROLLER,
                            Role.NATIONAL_CFR_HEAD,
                            Role.NATIONAL_FINANCIAL_CONTROLLER,
                            Role.NATIONAL_EVENTS_HEAD,
                            Role.CITY_PRESIDENT]
    national_level_roles.include?(self.role)
  end
  
  # -> Method returns role object by the role id passed to it.
  def self.getRolesByRoleid(role_id)
    return Role.where(:id => role_id)
  end
end
