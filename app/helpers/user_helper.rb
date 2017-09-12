module UserHelper
  
# START >>>>>>>>>>>>>>>> getDynamicManagers method start
  def getDynamicManagers(role_id,city_id)
	selectable_manager_roles={Role.CFR_POC => Role.CITY_FINANCIAL_CONTROLLER,
							  Role.VOLUNTEER => Role.CFR_POC,
							  Role.EVENTS_FELLOW => Role.CITY_FINANCIAL_CONTROLLER,
							  Role.CITY_PRESIDENT => Role.ADMINISTRATOR,
							  Role.NATIONAL_EVENTS_HEAD => Role.ADMINISTRATOR,
							  Role.NATIONAL_CFR_HEAD => Role.ADMINISTRATOR,
							  Role.NATIONAL_FINANCIAL_CONTROLLER=>Role.ADMINISTRATOR}
   
	if role_id=='' || city_id==''
	  return 400
	end
   
	@user_role = Role.find role_id
	role = @user_role.role
	
	#@user_role_by_city = UserRoleMap.where("role_id = ? and user_id IN (SELECT id FROM users WHERE city_id = ? and is_deleted=0)",role_id,city_id)
	@user_role_by_city = UserRoleMap.userRoleByCity(role_id,city_id)
		
	if @user_role_by_city.present?
	  if role == Role.CITY_PRESIDENT || role == Role.CFR_FELLOW|| role == Role.EVENTS_FELLOW
		return 405
	  end
	end
	
	#@userrole_maps = UserRoleMap.where("role_id = ? and user_id IN (SELECT id FROM users WHERE is_deleted=0)",role_id)
	@userrole_maps = UserRoleMap.userRoleMap(role_id)
	
	if @userrole_maps.present? 
	  if role == Role.NATIONAL_CFR_HEAD || role == Role.NATIONAL_EVENTS_HEAD || role == Role.NATIONAL_FINANCIAL_CONTROLLER
		return 410
	  end
	end
	
	if role == Role.ADMINISTRATOR || role == Role.CITY_PRESIDENT || role == Role.CFR_FELLOW || role == Role.CITY_FINANCIAL_CONTROLLER || role == Role.NATIONAL_CFR_HEAD || role == Role.NATIONAL_EVENTS_HEAD || role == Role.NATIONAL_FINANCIAL_CONTROLLER
	   return 420
	end
	
	@role_has_managers=false
	unless @user_role.has_no_selectable_managers?
	  @manager_role_name=selectable_manager_roles[@user_role.role]
	  @managers=User.find_managers_by_role_name_and_city_id @manager_role_name,city_id
	  if @managers.blank?
		if role == Role.VOLUNTEER || role == Role.CFR_POC || role == Role.EVENTS_FELLOW
		  # check for available managers or not for the following roles within selected city
		  # 1. Volunteer 2. Events Fellow 3. CFR POC
		  return 415
		else
		  return 420
		end
		
		#render :nothing => true,:text_status => 'User Role or Region not selected', :status =>404
		#return
	  else
		@role_has_managers=true
	  end
	end
	return @managers
  end
# END >>>>>>>>>>>>>>>> getDynamicManagers method end

# START >>>>>>>>>>>>>>>> set_possible_roles method start
  def set_possible_roles
	if User.has_role Role.ADMINISTRATOR,session[:roles]
	  @roles=Role.all
	  return
	end

	@logged_in_user_role_id = UserRoleMap.getRoleidByUserid(session[:session_user])
	#@roles = Role.where(:id => RoleReportTo.select("user_role_id").where(:manager_role_id => @logged_in_user_role_id))
	@roles = Role.getRolesByRoleid(RoleReportTo.getUserRoleidByManagerRoleid(@logged_in_user_role_id))
	has_volunteer=false
	@roles.each do |role|
	  if role.role == Role.VOLUNTEER
		has_volunteer=true
		break
	  end
	end
	unless has_volunteer
	  @volunteer_role=Role.where(role:Role.VOLUNTEER)
	  @volunteer_role.each do |role|
		@roles.push role
	  end
	end
  end
# END >>>>>>>>>>>>>>>> set_possible_roles method end

# START >>>>>>>>>>>>>>>> populate_user_managers_value method start
def populate_user_managers_value(role_param, city_param)
	@role_has_managers=true
	@disabled=true
	set_possible_roles   
	@managers = [] 
	if role_param=='' || city_param==''
	  #found_role = Role.where(:id=> UserRoleMap.select("role_id").where(:user_id => @user.id)).first
	  found_roles = Role.getRolesByRoleid(UserRoleMap.getRoleidByUserid(@user.id))
	  found_role = found_roles.to_a[0]
	  found_city_id = @user.city_id
	else
	  found_role= Role.find role_param
	  found_city_id= city_param
	  
	  @disabled=false
	end
	  if found_role.present?
		@selected_role = found_role.id  
		@user.role_id= @selected_role 
		
		selectable_manager_roles={Role.CFR_POC => Role.CITY_FINANCIAL_CONTROLLER,
								  Role.VOLUNTEER => Role.CFR_POC,
								  Role.EVENTS_FELLOW => Role.CITY_FINANCIAL_CONTROLLER,
								  Role.CITY_PRESIDENT => Role.ADMINISTRATOR,
								  Role.NATIONAL_EVENTS_HEAD => Role.ADMINISTRATOR,
								  Role.NATIONAL_CFR_HEAD => Role.ADMINISTRATOR,
								  Role.NATIONAL_FINANCIAL_CONTROLLER=>Role.ADMINISTRATOR}
		role = found_role
		@user_role_by_city = UserRoleMap.userRoleByCity(@selected_role,found_city_id)
		@manager_disabled=true
		if @user_role_by_city.present?
		  if role == Role.CITY_PRESIDENT || role == Role.CFR_FELLOW || role == Role.EVENTS_FELLOW
			@is_edit_user = false   
		  else
			@is_edit_user = true        
		  end
		end

		unless found_role.has_no_selectable_managers?
		  @selected_manager= []
		  @manager_role_name=selectable_manager_roles[found_role.role]
		  @managers=User.find_managers_by_role_name_and_city_id @manager_role_name,@user.city_id
		  #@current_managers= User.where(:id=>ReportsTo.select("manager_id").where(:user_id=> @user.id),:is_deleted =>0)
		  @current_managers = User.getUserByID(ReportsTo.getManageridByUserid(@user.id))
		  @managers.each do |manager|
			@current_managers.each do |curr_manager|
			  if manager.id==curr_manager.id
				@selected_manager.push manager.id
				@user.manager_id= manager.id
			  else
				@manager_disabled=false
			  end
			end
			
		  end
		  if @managers.blank?
			@manager_disabled= true
		  else
			@role_has_managers =true
			@manager_disabled= false
		  end
		end
	  end
  end
# END >>>>>>>>>>>>>>>> populate_user_managers_value method end

# START >>>>>>>>>>>>>>>> assign_managers method start
  def assign_managers
	auto_assigned_managers_roles={Role.CFR_POC => [Role.CFR_FELLOW],
								  Role.VOLUNTEER => [Role.EVENTS_FELLOW],
								  Role.CFR_FELLOW => [Role.CITY_PRESIDENT,Role.NATIONAL_CFR_HEAD],
								  Role.EVENTS_FELLOW => [Role.CITY_PRESIDENT,Role.NATIONAL_EVENTS_HEAD],
								  Role.CITY_FINANCIAL_CONTROLLER=> [Role.NATIONAL_FINANCIAL_CONTROLLER]}
	@user_role_maps = UserRoleMap.new
	@user_role_maps.assign_attributes({:role_id => @user.role_id, :user_id => @user.id})
	@user_role_maps.save(:validate=>false)
	user_role=Role.find(@user.role_id)
	if user_role.has_no_managers?
	  user_manager_map=ReportsTo.new
	  administrator = Role.where(role: Role.ADMINISTRATOR).first
	  user_manager_map.assign_attributes(:user_id => @user.id,:manager_id => administrator.id)
	  user_manager_map.save
	  return
	else
	  @reports_tos=[]
	  manager = ReportsTo.new
	  if @user.manager_id.present?
		manager.assign_attributes(:user_id => @user.id, :manager_id => @user.manager_id)
		@reports_tos.push manager
	  elsif user_role.role!=Role.CITY_FINANCIAL_CONTROLLER && user_role.role!=Role.CFR_FELLOW
		flash[:error] = MadConstants.error_message_no_manager_selected
		raise ActiveRecord::Rollback, 'City Level roles not assigned to anybody'
	  end
	end
	user_role = Role.find @user.role_id
	auto_assigned_managers_roles[user_role.role].each do |role_name|
	  @manager=nil
	  if Role.is_national_level_role? role_name
		@manager=User.find_single_manager_by_role_name role_name
	  else
		@manager=User.find_single_manager_by_role_name_and_city_id role_name,@user.city_id
	  end
	  if @manager.nil?
		flash[:error] = MadConstants.error_message_no_city_or_national_level_managers
		raise ActiveRecord::Rollback, 'City Level roles not assigned to anybody'
	  end
	  user_manager_map = ReportsTo.new
	  user_manager_map.user_id = @user.id
	  user_manager_map.manager_id = @manager.id
	  @reports_tos.push user_manager_map
	end
	@reports_tos.each do |reports_to|
	  reports_to.save(:validate => false)
	end
  end
# END >>>>>>>>>>>>>>>> assign_managers method end

  def getAutoAssignedManagersToJustBelowUser(role_id,city_id)
	auto_assigned_below_users_roles={[Role.CFR_FELLOW] => Role.CFR_POC,
									Role.EVENTS_FELLOW=> Role.VOLUNTEER ,
									Role.NATIONAL_CFR_HEAD => Role.CFR_FELLOW,
									Role.CITY_PRESIDENT => [Role.CFR_FELLOW, Role.EVENTS_FELLOW],
									Role.NATIONAL_EVENTS_HEAD =>Role.EVENTS_FELLOW,
									[Role.NATIONAL_FINANCIAL_CONTROLLER] => Role.CITY_FINANCIAL_CONTROLLER}
	  
	  
	  @user_role = Role.find role_id
	  role = @user_role.role
	  @reports_to= []
	  existing_below_user_roles= auto_assigned_below_users_roles[role]
	  
	  if existing_below_user_roles.present?
		 
		 if existing_below_user_roles.kind_of?(Array)
		  below_users_collections = existing_below_user_roles.to_a
		 else
		  below_users_collections = existing_below_user_roles.to_s.split(',')   
		 end
		 
		 below_users_collections.each do |exist_role|
		 
		   if Role.is_national_level_role? exist_role
			  @below_user=User.find_users_by_just_below_the_role_name exist_role  
		   else 
			  @below_user=User.find_users_by_just_below_the_role_name_and_city exist_role, city_id
		   end
		   
		   if @below_user.present?
			 @below_user.each do |child_user|
				user_manager_map = ReportsTo.new
				user_manager_map.user_id = child_user.id
				user_manager_map.manager_id = @user.id
				
				user_manager_map.save(:validate => false)
			  end
		   end
		 end
	  end
  end
end