class User < ActiveRecord::Base

  attr_accessor :total_donation_amount, :current_role, :subordinate_role, :role_id, :poc_id, :manager_id

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable
  validates :password, :presence=> true
  validates :phone_no, :uniqueness => {:scope => [:phone_no, :is_deleted]}, numericality: { only_integer: true }, allow_blank: false, :length => {:minimum => 10, :maximum => 12}
  validates :email, :uniqueness => {:scope => [:email, :is_deleted]}
  validates :first_name, :presence => true, :length => {:maximum => 55}
  validates :address, :length => {:maximum => 200}
  validates :email, :length => {:maximum => 55}
  validates :role_id, :presence => true
  validates :city_id, :presence => true
  validates_presence_of :manager_id, :if=> :manager_required?
  validates_format_of :email,:with => /\A[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]+\z/, :message => "doesn't look like an email address"

  has_many :reports_tos, :dependent => :delete_all
  has_many :managers , :through => :reports_tos

  has_many :inverse_reports_tos , :class_name => "ReportsTo" ,:foreign_key => "manager_id" ,:dependent => :delete_all
  has_many :subordinates , :through => :inverse_reports_tos ,:source => :user

  has_many :donations, :foreign_key => 'updated_by'
  has_many :event_donations, :foreign_key => 'updated_by'

  has_many :user_role_maps
  has_many :roles,:through => :user_role_maps

  belongs_to :city
  
  # -> Boolean method which returns true when the role of 
  #    the calling user object is Volunteer, CFR POC or 
  #    Events Fellow. Otherwise returns false.
  # -> Returns false when no role is assigned to user.
  def manager_required?
    if role_id.present?
      new_user_role = Role.find(role_id)
      if new_user_role.role == Role.VOLUNTEER || new_user_role.role == Role.CFR_POC || new_user_role.role == Role.EVENTS_FELLOW
        return true
      else
        return false
      end
    else 
      return false
    end
  end

  # -> Method returns city of the calling user object.
  def city
    City.find(city_id)
  end
  
  # -> Method overrides the rails provided default 'first_name' method
  def first_name
    capitalize_by_space_and_period(self.read_attribute(:first_name).to_s)
  end

  # -> Method overrides the rails provided default 'last_name' method
  def last_name
    capitalize_by_space_and_period(self.read_attribute(:last_name).to_s)
  end

  # -> Method returns full name of the calling user object.
  def name
    name = first_name
    if last_name.present?
      name = name + ' ' + last_name
    end
    return name
  end

  # Returs all the volunteers in the same city as the current user.
  def city_volunteers
    return User.where(:city_id => self.city_id)
  end
  
  # -> Method returns names of POC assigned to the user. 
  # -> If none found, returns 'No POC Assigned'
  def poc_names   
    poc_names = ''
    poc_users = User.find_by_sql("select u.* from users u join reports_tos rt on (u.id = rt.manager_id) 
                  join user_role_maps rm on (rt.manager_id = rm.user_id)
                  join roles r on (rm.role_id = r.id)  where r.role = '" + Role.CFR_POC.to_s + "' and rt.user_id = " + id.to_s);
    
    if poc_users.present?
      poc_users.each do |poc_user|
        if poc_names.empty?
        else
          poc_names += ', ' 
        end
        poc_names += poc_user.name
      end
    end
    if poc_names.empty?
      poc_names= 'No POC assigned'
    end
    return poc_names
  end

  # -> Method returns all POC role users in the city passed to it.
  def get_pocs_by_city_id(city_id_param)
    User.find_by_sql("select u.* from users u join user_role_maps rm on (u.id = rm.user_id)
      join roles r on (rm.role_id = r.id)  where u.city_id = "+ city_id_param +" and r.role = '" + Role.CFR_POC.to_s + "'");
  end

  # -> Method returns all managers of the given role passed to it.
  def get_managers_by_role_id(role_id_param)
    User.find_by_sql("select u.* from users u join user_role_maps rm on (u.id = rm.user_id)
      join role_report_tos rto on (rto.manager_role_id = rm.role_id) where rto.user_role_id = " + role_id_param + " and u.is_deleted = 0");
  end

  # -> Method returns all poc users.
  def get_all_pocs
    User.find_by_sql("select u.* from users u join user_role_maps rm on (u.id = rm.user_id)
      join roles r on (rm.role_id = r.id)  where r.role = '" + Role.CFR_POC.to_s + "' and u.is_deleted = 0");
  end

  # -> Method returns volunteers not assigned to the poc passed to it.
  def get_volunteers_not_assigned_to_poc(poc_id_param)
    User.find_by_sql("select distinct u.* from users u join reports_tos rt on
      (rt.user_id = u.id) join user_role_maps rm on (u.id = rm.user_id) join roles r on
      (rm.role_id = r.id) where rm.user_id != " + poc_id_param + " and r.role = '" + Role.VOLUNTEER.to_s + "' and u.is_deleted=0");
  end

  # -> Method returns managers by role name and the city id passed to it.
  def self.find_managers_by_role_name_and_city_id(role_name, city_id)
    return [] unless role_name
    puts role_name
    role = Role.where(role: role_name).take
    managers = User.joins(:user_role_maps).where(user_role_maps: {role_id: role.id},users:{city_id:city_id, is_deleted:0})
    return managers
  end

  # -> Method returns the first manager by role name and the city id passed to it.
  def self.find_single_manager_by_role_name_and_city_id(role_name,city_id)
    role = Role.where(role: role_name).take
    managers = User.joins(:user_role_maps).where(user_role_maps: {role_id: role.id},users:{city_id:city_id,is_deleted:0}).take
    return managers
  end

  # -> Method returns the first manager by role name passed to it.
  def self.find_single_manager_by_role_name(role_name)
    role = Role.where(role: role_name).take
    manager=User.joins(:user_role_maps).where(user_role_maps: {role_id: role.id},users:{is_deleted:0}).first
    return manager
  end
  
  def self.find_users_by_just_below_the_role_name(role_names)
      users = User.joins("join user_role_maps on (users.id = user_role_maps.user_id)").
              joins("join roles on (user_role_maps.role_id = roles.id)").where("roles.role in ('"+ role_names +"') and users.is_deleted=0")
      return users
  end
  
  def self.find_users_by_just_below_the_role_name_and_city(role_names,city_id)
      users = User.joins("join user_role_maps on (users.id = user_role_maps.user_id)").
              joins("join roles on (user_role_maps.role_id = roles.id)").where("roles.role in ('"+ role_names +"') and users.city_id= "+
               city_id.to_s+" and users.is_deleted=0")
      return users
  end

  def self.find_single_manager_by_role_id_and_city_id(role_id,city_id)
    managers=User.joins(:user_role_maps).where(user_role_maps: {role_id: role_id},users:{city_id:city_id,is_deleted:0}).take
    return managers
  end

  # -> Method returns the total amount of donations for the status passed to it.
  def total_amount_of_donations(status)
    Donation.where("updated_by = ? AND donation_status = ?",self.id,status).sum("donation_amount")
  end

  # -> Method returns the total amount of event donations for the status passed to it.
  def total_amount_of_event_donations(status)
    EventDonation.where("updated_by = ? AND donation_status = ?",self.id,status).sum("donation_amount")
  end
  
  # -> Method sets the current user's role map
  def set_current_user_role_map(user_roles_list)

    role_subordinate_map ={Role.CFR_POC => Role.VOLUNTEER,
                           Role.CITY_FINANCIAL_CONTROLLER => Role.CFR_POC,
                           Role.NATIONAL_FINANCIAL_CONTROLLER => Role.CITY_FINANCIAL_CONTROLLER,
                           Role.EVENTS_FELLOW => Role.VOLUNTEER}

    role_subordinate_map.each_pair do |manager_role,subordinate_role|
      if User.has_role manager_role,user_roles_list
        self.current_role= manager_role
        self.subordinate_role = subordinate_role
        return
      end
    end
    raise 'User has Role not Defined in Role Map.'
  end

  # -> Boolean method which returns true if the required roles passed to it is 
  #    in the roles list passed to it.
  def self.has_role(required_role, user_roles_list)
    user_roles_list.each do |role|
      if role.role == required_role
        return true
      end
    end
    false
  end
  
  # -> Boolean method which returns true is any of the permitted
  #    roles passed to it is also in the roles list passed to it.
  def self.has_role_from(permitted_roles, user_roles_list)
    permitted_roles.each do |permitted_role|
      if has_role permitted_role,user_roles_list
        return true
      end
    end
    return false
  end

  # -> Method returns all users matching the search query passed to it.
  # -> Returns all users if nothing is passed.
  def self.search(search = nil)
    if search
      User.where("concat(first_name,' ',last_name) LIKE ? 
              OR phone_no LIKE ? OR city_id IN (SELECT id FROM cities WHERE name LIKE ?)", 
              "%#{search}%", "%#{search}%", "%#{search}%")
    else
      User.all
    end
  end
  
  def self.find_for_authentication(conditions)
    super(conditions.merge(:is_deleted => false))
  end
  
  # -> Method which returns the user object by the id which is passed to it.
  def self.getUserByID(user_id)
    return User.where(:id=> user_id,:is_deleted =>0)
  end

  private

  # -> Method which capitalizes word passed to it.
  def capitalize_by_space_and_period(name)
    name.split(/\s|\./).map {|w| w.capitalize}.join(' ')
  end

end