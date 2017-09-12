class DonationsController < ActionController::Base
  include SmsHelper
  include EmailHelper
  include EmailTemplateHelper
  
  @basicauth = BasicAuth.find(:first)
  
  http_basic_authenticate_with :name => @basicauth.name, :password => @basicauth.password
  skip_before_filter :verify_authenticity_token
  
  before_action :set_donation, only: [:show, :edit, :update, :destroy]

  # GET /donations
  # GET /donations.json
  def index
    @donations = Donation.all
  end

  # GET /donations/1
  # GET /donations/1.json
  def show
    respond_to do |format|
      format.xml { render :xml => @donation.to_xml(:only => [:id]) }
    end
  end

  # GET /donations/new
  def new
    @donation = Donation.new
  end

  # GET /donations/1/edit
  def edit
  end

  # POST /donations
  # POST /donations.json

  # -> Create a new donation from params
  # -> Send SMS to donour about donation
  # -> Send mail to donour about donation
  def create
    if donation_params[:phone_no] == '' and  donation_params[:email_id] == ''

      unless(User.find(donation_params[:fundraiser_id]))
        # If there is no user with the given fundraiser ID, don't let the donation happen. That person has been deleted, most likely.
        render text: "<errors><error>Error: Can't find user in the database. Please logout - then login and try again.</error></errors>"
        return 0
      end
      if(donation_params[:amount].to_i > 200)
        # If there is no phone number or email id, and the amount is greater than 200, show error. Else, let it enter.
        render text: "<errors><error>Error: Phone AND Email empty.</error></errors>"
        return 0
      end
      @donour = nil
    else 
      @donour = Donour.find_unique(donation_params[:phone_no], donation_params[:email_id])
    end
    
    # check donation made for what ? Event or Product or Dream Tee donations
    
    @donation = Donation.new
    
    respond_to do |format|
      if @donour.nil?
        # Creates new donour entry for the information found
        @donour = Donour.new
        
        @donour.assign_attributes({:first_name => donation_params[:first_name], 
                                    :phone_no => donation_params[:phone_no], :email_id => donation_params[:email_id], 
                                    :address => donation_params[:address]})
        
        Rails.logger.warn @donour.inspect
        if @donour.save
           
        else
          format.html { render action: 'new' }
          format.xml { render xml: @donour.errors, status: :unprocessable_entity }
        end
        
      else
        # already existed donour found
      end
      
      if !@donour.nil?
        product_or_event_name = ''
        if donation_params[:donation_type].to_s == 'GEN'
          @gen_product = CfrProduct.find_by_is_other_product(0)
          @donation.assign_attributes(:product_id => @gen_product.id)
          product_or_event_name = 'General Donation'
        else
          @donation.assign_attributes(:product_id => donation_params[:product_id])
          product = CfrProduct.find(donation_params[:product_id])
          if product.present?
            product_or_event_name = product[:name].to_s
          else
            product_or_event_name = 'General Donation'
          end
        end
        
        @donation.assign_attributes({:donation_type => donation_params[:donation_type], :version => 1, 
                                    :fundraiser_id => donation_params[:fundraiser_id], :donour_id => @donour.id, 
                                    :donation_status => Donation.STATUS_TO_BE_APPROVED_BY_POC,
                                    :eighty_g_required => donation_params[:eighty_g_required], 
                                    :donation_amount => donation_params[:amount],
                                    :updated_by => donation_params[:fundraiser_id],
                                    :comment => donation_params[:comment]})
        
        if donation_params[:eighty_g_required].to_s == 'true'
          @donation.assign_attributes(:eighty_g_required => true)
        else
          @donation.assign_attributes(:eighty_g_required => false)
        end

        # 2 is RoR API. Another option is to pass from the App - donation_params[:source_id]
        @donation.assign_attributes({:source_id => 2})
        
        if @donation.save
          donour_name = donation_params[:first_name]
          if donation_params[:last_name].present?
            donour_name += ' ' + donation_params[:last_name]
          end

          phone_number = donation_params[:phone_no]
          email_address = donation_params[:email_id]

          if donation_params[:phone_no] == '' and  donation_params[:email_id] == ''
            fundraiser = User.find(donation_params[:fundraiser_id])
            phone_number = fundraiser.phone_no
            email_address = fundraiser.email
          end
          
          begin
            puts 'sms sending started.....'
            # If donor didn't give a phone number, use fundraiser's number.
            send_ack_sms(donour_name, donation_params[:amount], phone_number)
            
            puts 'sms sending ended.....'
          rescue
            # alert that sms not sent
          end
          
          if email_address.present?
            begin   
              if @donation.eighty_g_required.to_s == 'true'
                email_text = ack_mail_template_with_eighty_g(donour_name, email_address, donation_params[:amount], @donation[:id], product_or_event_name)

              else
                email_text = ack_mail_template(donour_name, email_address, donation_params[:amount], @donation[:id], product_or_event_name)
              end
              
              send_mails( email_address , 'Donation Acknowledgment', email_text)
            rescue
              # alert that mail not sent
            end
          end

          format.html { redirect_to @donation, notice: 'Donation added successfully.' }
          #format.json { render action: 'show', status: :found, location: @donation }
          format.xml { render action: 'show', status: :created, location: @donation }    
        else 
          format.html { render action: 'new' }
          format.xml { render xml: @donation.errors, status: :unprocessable_entity }
        end
      end
    end
  end

  # PATCH/PUT /donations/1
  # PATCH/PUT /donations/1.json
  def update
    respond_to do |format|
      if @donation.update(donation_params)
        format.html { redirect_to @donation, notice: 'Donation was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @donation.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /donations/1
  # DELETE /donations/1.json
  def destroy
    @donation.destroy
    respond_to do |format|
      format.html { redirect_to donations_url }
      format.json { head :no_content }
    end
  end

  # This function will send the acknolegment sms/email for the specified donation ID. Used to send the ack mail again - in case it was missing.
  def send_acknowledgement
  	@donation = Donation.find(params[:donation_id])

	if @donation.donour.email_id.present?
	    #begin
	      if @donation.eighty_g_required.to_s == 'true'
	        email_text = ack_mail_template_with_eighty_g(@donation.donour.first_name, @donation.donour.email_id, @donation.donation_amount, @donation.id, '')
	      else
	        email_text = ack_mail_template(@donation.donour.first_name, @donation.donour.email_id, @donation.donation_amount, @donation.id, '')
	      end
	      
	      send_mails(@donation.donour.email_id , 'Donation Acknowledgment', email_text)
	    # rescue
	    #   # alert that mail not sent
	    #   puts "Error sending email"
	    # end
	end

  	render :text => email_text
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_donation
      @donation = Donation.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def donation_params
      params.permit(:first_name,:last_name,:email_id,:phone_no,:address,:eighty_g_required, 
        :donation_amount, :amount, :donation_type, :version, :fundraiser_id, :donour_id, 
        :donation_status, :product_id, :source_id, :comment)
    end
end