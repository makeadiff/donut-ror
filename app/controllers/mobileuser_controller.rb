class MobileuserController  < ActionController::Base
  @basicauth = BasicAuth.find(:first)
  
  http_basic_authenticate_with :name => @basicauth.name, :password => @basicauth.password
  skip_before_filter :verify_authenticity_token
  
  before_action :set_user, only: [:show, :edit, :update, :destroy]

  # GET /users
  # GET /users.json
  def index
    # @users = User.all
  end

  # GET /users/1
  # GET /users/1.json
  def show
    @user = User.find_by_phone_no(user_params[:phone_no])

    respond_to do |format|
      if @user.nil? 
        raise ActionController::RoutingError.new('Not Found')
      else 
        @existing_users= User.where(:id=> UserRoleMap.select("user_id").where(:role_id=> Role.where(role: "Volunteer"))).where(:phone_no=> @user.phone_no)

        if @existing_users.present?
          render :xml => @user.to_xml(:only => [:id,:is_fc])
        else
          raise ActionController::RoutingError.new('Not Found')
        end
      end
    end
  end

  # GET /users/new
  def new
    @user = User.new
  end
  
  # GET /users/new
  def login
    @user = User.find_by_phone_no
  end
  
  # GET /users/1/edit
  def edit
  end
  
  # POST /users
  # POST /users.json
  def create
    # # Why RAW SQL? Because the ORM version was SUPER slow! More than 30 secs to exeucte. Hence, this.
    # query = "SELECT U.* FROM `users` U 
    #             INNER JOIN `user_role_maps` RM ON RM.user_id=U.id
    #             INNER JOIN `roles` R ON R.id=RM.role_id
    #             WHERE R.role='Volunteer' AND U.`phone_no` = '"+user_params[:phone_no]+"' AND U.is_deleted='0'"
    # user = User.find_by_sql query

    # User login possibilites...
    # Phone number not found.
    # Found - but deleted(is_deleted = 1)
    # Role is not 'Volunteer'
    # Role is not assigned. At all.
    user = User.find_by_phone_no user_params[:phone_no]

    # Phone number not found.
    unless user
      #raise ActionController::RoutingError.new('Not Found')
      @data = {
        :id => 0,
        :is_fc => 0,
        :message => "Couldn't find any users with that phone number(" + user_params[:phone_no] + ")",
      }
    else

      # Found - but deleted(is_deleted = 1)
      if(user[:is_deleted] == '1')
        @data = {
          :id => 0,
          :is_fc => 0,
          :message => "User '" + user[:first_name] + " " + user[:last_name] + "' has been deleted from the system."
        }
      else
        roles_query = "SELECT R.* FROM `user_role_maps` RM 
                  INNER JOIN `roles` R ON R.id=RM.role_id
                  WHERE RM.user_id='" + user[:id].to_s + "'"
        roles = Role.find_by_sql roles_query

        is_fc = 0
        vol = 0

        puts roles.inspect

        roles.each { |role|
          # Role is not 'Volunteer'
          # Role is not assigned. At all.
          if role[:role] == "Volunteer"
            vol = 1
          elsif role[:role] == "Finance Fellow"
            is_fc = 1
          end
        }


        if vol == 0
          @data = {
            :id => 0,
            :is_fc => 0,
            :message => "User '" + user[:first_name] + " " + user[:last_name] + "' is not assigned a POC. Please let your CFR Fellow know."
          }
        else
          @data = {
            :id => user[:id],
            :is_fc => is_fc,
            :message => "Login successful."
          }
        end
      end
    end
  end

  # PATCH/PUT /users/1
  # PATCH/PUT /users/1.json
  def update
    respond_to do |format|
      if @user.update(user_params)
        format.html { redirect_to @user, notice: 'User was successfully updated.' }
        format.xml { head :no_content }
      else
        format.html { render action: 'edit' }
        format.xml { render xml: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /users/1
  # DELETE /users/1.json
  def destroy
    @user.destroy
    respond_to do |format|
      format.html { redirect_to users_url }
      format.xml { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_user
      @user = User.find_by_phone_no(params[:phone_no])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def user_params
      params.permit(:username, :password, :first_name, :last_name, :phone_no)
    end
end

