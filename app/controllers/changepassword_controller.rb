class ChangepasswordController < ApplicationController
  
  def show
    @user = User.find_by_id(session[:session_user])
    puts params[:new_password]
    @newpass = params[:new_password]
    puts @newpass.length
    if ((params[:new_password].to_s== params[:confirm_password].to_s))
      cost = 10
      encrypted_password = ::BCrypt::Password.create("#{params[:new_password]}#{nil}", :cost => cost).to_s
      puts encrypted_password
      
      
      @user.password = params[:new_password]
      @user.password_confirmation = params[:new_password]
      @user.save

      puts 'Password changed.....'

    if @user.present?
        flash[:alert] = "User was successfully updated with new password."
          redirect_to homes_path
     end
     else
       puts 'Some error in password'
       redirect_to changepassword_path
     end
    
  end
  
end
