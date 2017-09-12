class VolunteersController < ApplicationController
  before_action :set_volunteer, only: [:show, :edit, :update, :destroy]
  
  def dynamic_pocs
    @pocs = User.new.get_pocs_by_city_id(params[:city_id])
    puts @pocs
    render :partial => "pocs", :object => @pocs
  end
  
  # GET /users
  # GET /users.json
  def index
    @subordinates = User.where(:id => UserRoleMap.select("user_id").where(:role_id => Role.select("id").where(:role => MadConstants.volunteer)))
  end

  # GET /users/1
  # GET /users/1.json
  def show
    @city = City.find(@volunteer.city_id)
  end

  # GET /users/new
  def new
    @volunteer = User.new
    @roles_array = Role.all
    @managers = User.all
    @pocs = User.all
  end

  # GET /users/1/edit
  def edit
    @volunteer.encrypted_password = '' 
    @managers = User.all
    @pocs = User.all
  end

  # POST /users
  # POST /users.json
  def create
    @volunteer = User.new(user_params)
    cost = 10
    
    encrypted_password = ::BCrypt::Password.create("#{user_params[:encrypted_password]}#{nil}", :cost => cost).to_s
    @volunteer.assign_attributes(:encrypted_password => encrypted_password)
    
    if @volunteer.role_id.nil? && @volunteer.poc_id.present? 
        @new_user_role = Role.find_by_role(MadConstants.volunteer)
        @volunteer.assign_attributes(:role_id => @new_user_role.id)
    end
    
    respond_to do |format|
      if @volunteer.save
        @user_role_maps = UserRoleMap.new
        @user_role_maps.assign_attributes({:role_id => @volunteer.role_id, :user_id => @volunteer.id})
        @user_role_maps.save(:validate=>false)
        
        if @volunteer.poc_id.present?
          @reports_tos = ReportsTo.new
          @reports_tos.assign_attributes(:user_id => @volunteer.id, :manager_id => @volunteer.poc_id)  
          @reports_tos.save(:validate => false)
        end
        
        format.html { redirect_to @volunteer, notice: 'Volunteer was successfully created.' }
        format.json { render action: 'show', status: :created, location: @volunteer }
      else
        format.html { render action: 'new' }
        format.json { render json: @volunteer.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /users/1
  # PATCH/PUT /users/1.json
  def update
    respond_to do |format|
      if @volunteer.update(user_params)
        format.html { redirect_to @volunteer, notice: 'Volunteer was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @volunteer.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /users/1
  # DELETE /users/1.json
  def destroy
    @volunteer.destroy
    respond_to do |format|
      format.html { redirect_to users_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_volunteer
      @volunteer = User.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def volunteer_params
      params.require(:user).permit(:encrypted_password, :email, :reset_password_token, :reset_password_sent_at, 
      :remember_created_at, :sign_in_count, :current_sign_in_at, :last_sign_in_at, :current_sign_in_ip, 
      :last_sign_in_ip, :created_at, :updated_at, :address, :first_name, :last_name, :phone_no, 
      :role_id,:city_id, :poc_id, :manager_id)
    end
end

