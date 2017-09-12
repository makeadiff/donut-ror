class MobileReportsController < ActionController::Base
	@basicauth = BasicAuth.find(:first)
	  
	http_basic_authenticate_with :name => @basicauth.name, :password => @basicauth.password
	skip_before_filter :verify_authenticity_token
	  
	
  	
  	def vol_report
		
		@donations = Donation.joins(:donour).where(:fundraiser_id => user_params[:id]).reverse()

		respond_to do |format|
			format.json {render :json => @donations.as_json(:only => [:id, :donation_amount, :donation_status, :created_at], :include => {:donour => {:only =>[:first_name, :last_name, :phone_no, :email_id]}})}
			format.xml
			format.html
		end
	end

	  
  	private
	 	def user_params
      		params.permit(:id)
		end
  
  
	
  
end
