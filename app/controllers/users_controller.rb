 class UsersController < ApplicationController

  helper_method :sort_column, :sort_direction
  before_action :set_user, only: [:show, :edit, :update, :destroy]
  before_filter :validate_user_role
  @permitted_roles = [Role.NATIONAL_CFR_HEAD, Role.ADMINISTRATOR, Role.CFR_POC, Role.CFR_FELLOW, Role.CITY_PRESIDENT, Role.EVENTS_FELLOW, Role.NATIONAL_EVENTS_HEAD, Role.CFR_POC, Role.CITY_FINANCIAL_CONTROLLER, Role.NATIONAL_FINANCIAL_CONTROLLER]
  class << self; attr_reader :permitted_roles end;

  include UserHelper
  
  def dynamic_managers    
    @managers = []
    @returnFromGetDynamicManagers = []
    role_id= params[:role_id]
    city_id=params[:city_id]
    @returnFromGetDynamicManagers = getDynamicManagers(role_id,city_id)
    if @returnFromGetDynamicManagers.to_s == "400"
      render :nothing => true,:text_status => 'User Role or Region not selected', :status =>400
      return
    elsif @returnFromGetDynamicManagers.to_s == "405"
      render :nothing => true,:text_status => 'You can not create this same role for same city', :status =>405
      return
    elsif @returnFromGetDynamicManagers.to_s == "410"
      render :nothing => true,:text_status => 'You can not create another role of this type', :status =>410
      return
    elsif @returnFromGetDynamicManagers.to_s == "420"
      render :nothing => true# No need of managers
      return
    elsif @returnFromGetDynamicManagers.to_s == "415"
      render :nothing => true,:text_status => 'No Managers Found for this City. Please Create them', :status =>415
      return
    else
      @managers = @returnFromGetDynamicManagers
    end
    render :partial => 'managers', :object => @managers
  end

  def dynamic_managers_by_city
    puts params[:city_id]
  end

  def dynamic_pocs
    @pocs = User.new.get_pocs_by_city_id(params[:city_id])
    render :partial => "pocs", :object => @pocs
  end

  # GET /users
  # GET /users.json
  def index
    flash[:error]=""
    flash[:alert]=""
    if User.has_role Role.ADMINISTRATOR,session[:roles]
      @users = sort_column # changed this line for the pagination & searching
      number_of_users = @users.length
      if number_of_users < 1
        flash[:alert] = "No User found"
      end
    else
      redirect_to MadConstants.new_users_page
    end
  end

  # GET /users/1
  # GET /users/1.json
  def show
    @city = City.find(@user.city_id)
    puts @user.inspect
  end

  # GET /users/new
  def new
    @roles_array = Role.all
    @user = User.new
    set_possible_roles
    @managers = []
  end

  # GET /users/1/edit
  def edit
    populate_user_managers_value("", "")
  end
  
  # PATCH/PUT /users/1
  # PATCH/PUT /users/1.json
  def update
    #found_role = Role.where(:id=> UserRoleMap.select("role_id").where(:user_id => @user.id)).first
    # found_roles = Role.getRolesByRoleid(UserRoleMap.getRoleidByUserid(@user.id))
    # found_role = found_roles.to_a[0]
    # @selected_role = found_role.id
    # @user.assign_attributes(:role_id => found_role.id)

    # Assign user the selected Roles
    @user.assign_attributes(:role_id => user_params[:role_id])

    @disabled=true
    @user.assign_attributes({:first_name => user_params[:first_name],
                :last_name => user_params[:last_name],
                :email => user_params[:email],
                :city_id => user_params[:city_id],
                :phone_no => user_params[:phone_no],
                :address => user_params[:address],
                :manager_id => user_params[:manager_id]
                })
    cost = 10
    encrypted_password = ::BCrypt::Password.create("#{user_params[:password]}#{nil}", :cost => cost).to_s
    @user.assign_attributes(:encrypted_password => encrypted_password, :password => user_params[:password])
    @user.transaction do
      begin
        if @user.save
          UserRoleMap.delete_all(:user_id=> @user.id)
          @reports_tos= ReportsTo.where(:user_id=> @user.id)
          if @reports_tos.present?
            @reports_tos=ReportsTo.delete_all(:user_id=> @user.id)
          end
          assign_managers
          respond_to do |format|
            format.html {redirect_to @user, notice: 'Users was successfully updated.'}
          end
        else
        respond_to do |format|
          format.html {render action: 'edit'}
          populate_user_managers_value("","")
        end        
      end
      rescue ActiveRecord::Rollback
        handle_rollback
      end
    end
  end

  # POST /users
  # POST /users.json
  def create
    @user = User.new(user_params)
    cost = 10
    encrypted_password = ::BCrypt::Password.create("#{user_params[:password]}#{nil}", :cost => cost).to_s
    @user.assign_attributes(:encrypted_password => encrypted_password, :is_deleted => false)
    @selected_role = user_params[:role_id]
    @user.transaction do
      begin
        if @user.save
          auto_assigned_managers_to_just_below_users
          assign_managers
          respond_to do |format|
            format.html { redirect_to @user, notice: 'Users was successfully created.' }
            format.json { render action: 'show', status: :created, location: @user }
          end
        else
          set_possible_roles
          respond_to do |format|
            if @selected_role.to_s != "" || user_params[:city_id] != ""
              populate_user_managers_value(@selected_role,user_params[:city_id])
            end
            format.html { render action: 'new' }
            format.json { render json: @user.errors, status: :unprocessable_entity }
          end
        end
      rescue ActiveRecord::Rollback
        handle_rollback
      end
    end
  end

# DELETE /users/1
# DELETE /users/1.json
  def destroy
    @user.transaction do
      begin
        if @user.update_attribute(:is_deleted, 'true')
          @user.update_attribute(:phone_no, '')# phone no and email are considered to be unique, so flushing them into empty for deleted users.
          @user.update_attribute(:email, '')
          respond_to do |format|
            format.html { redirect_to '/users' }
            format.json { head :no_content }
          end 
        end
      rescue Exception=>e 
        logger.warn "in error ...... #{e}"
      end
    end
  end
  
  private
  
  def validate_user_role
    validate_user *UsersController.permitted_roles, session[:roles], MadConstants.home_page
  end
# Use callbacks to share common setup or constraints between actions.
  def set_user
    @user = User.find(params[:id])
  end

  def sort_column
    @sort_field = ''
    if params[:sort].to_s == 'Phone no'
      @sort_field = 'users.phone_no '
    elsif params[:sort].to_s == 'Role'
      @sort_field = 'roles.role '
    elsif params[:sort].to_s == 'City'
      @sort_field = 'cities.name '
    else
      @sort_field = 'users.first_name'
    end
    User.select("DISTINCT users.*").joins("LEFT JOIN `user_role_maps` ON `user_role_maps`.user_id=`users`.id LEFT JOIN `roles` ON `roles`.id=`user_role_maps`.role_id").joins(:city).where('users.is_deleted=0').search(params[:search]).order(@sort_field + ' ' + sort_direction).paginate(:per_page => 10, :page => params[:page])
  end

  def sort_direction
    %w[asc desc].include?(params[:direction]) ? params[:direction] : "asc"
  end
  
  def auto_assigned_managers_to_just_below_users
      role_id= @user.role_id
      city_id= @user.city_id
      if role_id=='' || city_id==''
        render :nothing => true,:text_status => 'User Role or Region not selected', :status =>400
        return
      end
      getAutoAssignedManagersToJustBelowUser(role_id,city_id)
  end

# Never trust parameters from the scary internet, only allow the white list through.
  def user_params
    params.require(:user).permit(:password, :email, :reset_password_token, :reset_password_sent_at,
                                 :remember_created_at, :sign_in_count, :current_sign_in_at, :last_sign_in_at, :current_sign_in_ip,
                                 :last_sign_in_ip, :created_at, :updated_at, :address, :first_name, :last_name, :phone_no,
                                 :role_id,:city_id, :poc_id, :manager_id)
  end
  
  def handle_rollback
    set_possible_roles
    if flash[:error].nil?
       flash[:error] = MadConstants.error_message
    end
    redirect_to :action => :new
    raise ActiveRecord::Rollback
  end
end