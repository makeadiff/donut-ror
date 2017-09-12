class FreePoolController < ApplicationController
  
  before_filter :validate_user_role
  @permitted_roles = [Role.ADMINISTRATOR, Role.CFR_FELLOW, Role.EVENTS_FELLOW]
  class << self; attr_reader :permitted_roles end
  
  helper_method :sort_column, :sort_direction

  def show
    flash[:error]=""
    flash[:alert]=""
    @free_pool_users=[]
  end

  # -> To dynamically generate free pool users, populating using JS
  def dynamic_free_pool_users
    city_id = params[:city_id]
    @free_pool_users = sort_column city_id
    @pocs=get_pocs_by_city_id(city_id)
    render :partial => 'dynamic_free_pool_users', :object => @free_pool_users
  end

  def assign
    poc_id=params[:user][:manager_id]
    user_id= params[:user_id]
    if poc_id.empty? || user_id.nil?     
      render :nothing => true
      return    
    end
    user_manager_map= ReportsTo.new
    user_manager_map.assign_attributes(:manager_id => poc_id,:user_id => user_id)
    volunteer_role_id = get_role_id_by_role_name Role.VOLUNTEER
    user_role_map=UserRoleMap.new
    user_role_map.assign_attributes(:role_id => volunteer_role_id,:user_id => user_id)
    user_manager_map.transaction do
      begin
        unless user_role_map.save  &&  user_manager_map.save
          raise ActiveRecord::Rollback
        end
      rescue ActiveRecord::Rollback
        respond_to do |format|
          format.js {  render :nothing => true, :status => 500}
          return
        end
      end
    end
    respond_to do |format|
      format.js {  render :json => user_id.to_s , :status => 200}
    end
  end

  private
  def set_user
    @user = User.find(params[:id])
  end

  def sort_column(city_id)
    @sort_field = ''
    if params[:sort].to_s == 'Phone no'
      @sort_field = 'users.phone_no '
    else
      @sort_field = 'users.first_name'
    end
    volunteer_role_id=get_role_id_by_role_name Role.VOLUNTEER
    user_ids=User.joins(:user_role_maps).where('user_role_maps.role_id = ? AND users.city_id= ?',volunteer_role_id,city_id).select('users.id')
    if user_ids.empty?
      return User.where(:city_id => city_id)
    end
    User.where('users.id NOT IN (?) AND users.is_deleted = 0 AND users.city_id= ?',user_ids,city_id)
  end

  def get_role_id_by_role_name(role_name)
    volunteers_role=Role.where(:role => role_name)
    volunteer_id=0
    volunteers_role.each do |role|
      volunteer_id=role.id
    end
    volunteer_id
  end

  def sort_direction
    %w[asc desc].include?(params[:direction]) ? params[:direction] : "asc"
  end

  def get_pocs_by_city_id(city_id_param)
    User.find_by_sql("select u.* from users u join user_role_maps rm on (u.id = rm.user_id)
      join roles r on (rm.role_id = r.id)  where u.is_deleted = 0 and u.city_id = "+ city_id_param +" and r.role = '" + Role.CFR_POC + "'");
  end
  
  private
  def validate_user_role
    validate_vol_user *FreePoolController.permitted_roles, session[:roles], MadConstants.home_page
  end
  
  def validate_vol_user(*permitted_roles,user_role_list,redirection_page)
    permitted_roles.each do |role|
      if(User.has_role(role,user_role_list))
        return
      end
    end
    redirect_to redirection_page, :flash => {:info => MadConstants.permission_denied}
  end
  
end
