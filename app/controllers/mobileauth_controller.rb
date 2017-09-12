class MobileauthController  < ActionController::Base
  @basicauth = BasicAuth.find(:first)
  
  http_basic_authenticate_with :name => @basicauth.name, :password => @basicauth.password
  skip_before_filter :verify_authenticity_token
  
  before_action :set_user, only: [:create]

  # POST /mobileauth
  def create
    if @user.nil?
      puts "No User"
       @data = {
        :id => 0
      }
    else
      if @user.valid_password?(user_params[:password])
      	user_id = @user[:id]
      	
      	query = "SELECT U.* FROM `users` U 
                      INNER JOIN `user_role_maps` RM ON RM.user_id=U.id
                      INNER JOIN `roles` R ON R.id=RM.role_id
                      WHERE R.role='Volunteer' AND U.`phone_no` = '"+user_params[:phone_no]+"' AND U.is_deleted='0'"

      	user_query = User.find_by_sql query

      	if user_query.empty?
      	  @data = {
      	    :id => -1

      	  }
      	else
      	  @data = {
      	  :id => user_id

      	}
      	end
      
      else
      	@data = {
          :id => 0       
        }
      end
    end
  end
  
  #PUT/PATCH
  def update
    
  @user = User.find_by_id(params[:id])
  cost = 10
  encrypted_password = ::BCrypt::Password.create("#{user_params[:password]}#{nil}", :cost => cost).to_s
  
  if @user.update_attribute(:encrypted_password, encrypted_password)
      puts "Yes"
    else
       Rails.logger.info(@user.errors.messages.inspect)
      puts "No"
    end
  end


  private
    # Use callbacks to share common setup or constraints between actions.
    def set_user
      @user = User.find_by_phone_no(params[:phone_no])
 
    end
    
    def user_update_params
      # NOTE: Using `strong_parameters` gem
      params.permit(:password, :id)
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def user_params
      params.permit(:username, :password, :first_name, :last_name, :phone_no)
    end
end

