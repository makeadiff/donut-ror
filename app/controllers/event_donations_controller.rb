class EventDonationsController < ActionController::Base
  include SmsHelper
  include EmailHelper
  include EmailTemplateHelper
  
  @basicauth = BasicAuth.first
  
  http_basic_authenticate_with :name => @basicauth.name, :password => @basicauth.password
  skip_before_filter :verify_authenticity_token
  
  before_action :set_donation, only: [:show, :edit, :update, :destroy]

  # GET /event_donations
  # GET /event_donations.json
  def index
    @donations = EventDonation.all
  end

  # GET /event_donations/1
  # GET /event_donatinos/1.json
  def show
    respond_to do |format|
      format.xml { }
      format.html { render 'show' }
    end
  end

  # GET /event_donations/new
  def new
    @donation = EventDonation.new
  end

  # GET /event_donations/1/edit
  def edit
  end

  # POST /event_donations
  # POST /event_donations.json
 
  # -> Create a new event donation
  # -> Send confirmation sms to donour
  def create
    @donour = Donour.find_unique(donation_params[:phone_no], donation_params[:email_id])
    
    # check donation made for what ? Event or Product or Dream Tee donations
        
    respond_to do |format|
      if @donour.nil?
        # Creates new donour entry for the information found
        @donour = Donour.new
        
        @donour.assign_attributes({:first_name => donation_params[:first_name], :last_name => donation_params[:last_name], 
                                    :phone_no => donation_params[:phone_no], :email_id => donation_params[:email_id], 
                                    :address => donation_params[:address]})

        Rails.logger.warn @donour.inspect
        if @donour.save
           
        else
          # format.html { render action: 'new' }
          # format.xml { render xml: @donour.errors, status: :unprocessable_entity }
          puts @donour.errors.inspect
        end

        
      else
        # already existed donour found
      end
      
      if !@donour.nil?

        @donation = EventDonation.new({:donation_type => donation_params[:donation_type], :version => 1, 
                                    :fundraiser_id => donation_params[:fundraiser_id], :donour_id => @donour.id, 
                                    :donation_status => Donation.STATUS_TO_BE_APPROVED_BY_EVENT_HEAD,
                                    :eighty_g_required => donation_params[:eighty_g_required], 
                                    :event_id => donation_params[:event_id],
                                    :event_ticket_type_id => donation_params[:ticket_type_id],
                                    :donation_amount => donation_params[:amount],
                                    :updated_by => donation_params[:fundraiser_id],
                                    :source_id => donation_params[:source_id]})
        
        assign_donation_amounts(@donation)

        if @donation.save
          send_confirmation_notification(@donation)
          
          # send confirmation sms to donour
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

  def assign_donation_amounts(donation)
    don_ticket_type = donation.event_ticket_type_id
    if don_ticket_type > 0
      donation.donation_amount = EventTicketType.find(don_ticket_type).ticket_price.to_f
    end
  end
  
  # -> Send confirmation sms and email
  def send_confirmation_notification(donation)
    donour = Donour.find(donation.donour_id)
    don_tick_type = donation.event_ticket_type_id.to_i

    if donour.present?
      product_or_event_name = ''
      begin
        event = Event.find(donation.event_id)
        product_or_event_name = event.event_name
      rescue ActiveRecord::RecordNotFound
        product_or_event_name = 'General Donation'
      end
      donour_name = donour.first_name
      if donour.last_name.present?
        donour_name += ' ' + donour.last_name
      end
      begin
        event_confirmation_sms(donour_name, 
                      donation.donation_amount.to_s, 
                      donour.phone_no.to_s,product_or_event_name, don_tick_type)
      rescue
        puts 'SMS cannot be sent'
      end
      if donour.email_id.present?
        if don_tick_type > 0
          email_text = confirmation_mail_template_for_event(donour_name, donour.email_id,
                                                     donation.donation_amount.to_s, 
                                                     donation.id.to_s, 
                                                     product_or_event_name)
        elsif don_tick_type == -1
          email_text = confirmation_sponser_mail_template(donour_name, donation.donation_amount.to_s)
        elsif don_tick_type == -2
          email_text = confirmation_otd_mail_template(donour_name, donation.donation_amount.to_s)
        elsif don_tick_type == -3
          email_text = confirmation_thankyou_mail_template
        end
        begin
          send_mails( donour.email_id , 'Donation Confirmation', email_text)
        rescue
          puts 'Email cannot be sent'
        end
      end 
    end
  end

  # PATCH/PUT /event_donations/1
  # PATCH/PUT /event_donations/1.json
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

  # DELETE /event_donations/1
  # DELETE /event_donations/1.json
  def destroy
    @donation.destroy
    respond_to do |format|
      format.html { redirect_to event_donations_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_donation
      @donation = EventDonation.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def donation_params
      params.permit(:first_name,:last_name,:email_id,:phone_no,:address,:eighty_g_required, 
        :donation_amount, :amount, :donation_type, :version, :fundraiser_id, :donour_id, :event_ticket_type_id,
        :donation_status, :event_id, :ticket_type_id, :source_id)
    end
end
