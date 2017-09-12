class EventsDonationApprovalsController < ApplicationController
  include SmsHelper
  include EmailHelper
  include EmailTemplateHelper
  
  before_filter :validate_user_role

  @permitted_roles = [Role.EVENTS_FELLOW,
                      Role.CITY_FINANCIAL_CONTROLLER,
                      Role.NATIONAL_FINANCIAL_CONTROLLER]
                      
  class << self; attr_reader :permitted_roles end
  def show
    flash[:error]=""
    flash[:alert]=""
    begin
      @approver= User.find(session[:session_user]) if @approver.nil?
      @approver.set_current_user_role_map session[:roles]
      donation_status_by_role = EventDonation.get_approval_status_by_role @approver.current_role
      @subordinates=[]

      # This will make all the volunteers in the same city subordinate to the current user for this action. 
      @approver.city_volunteers.each do |subordinate|
        puts subordinate
        total_amount_of_donations=subordinate.total_amount_of_event_donations(donation_status_by_role[:current_status])
        unless total_amount_of_donations == 0
          subordinate.total_donation_amount =  total_amount_of_donations
          @subordinates.push subordinate
        end
      end

      @sub_hash = []
      @subordinates.each do |subordinate|
        subordinate_hash = {}
        subordinate_hash[:sub] = subordinate
        subordinate.event_donations.each do |donation|
          event_name = Event.find(donation.event_id).event_name
          subordinate_hash[event_name] ||= []
          subordinate_hash[event_name].push(donation)
        end
        @sub_hash.push(subordinate_hash)
      end
            
      @subordinate_event_donations = []
      @uniq_event_ids = []
      @subordinates.each do |subordinate| 
        subordinate.event_donations.each do |donation|
          if donation.donation_status == EventDonation.get_approval_status_by_role(@approver.current_role)[:current_status]
            @subordinate_event_donations.push(donation)
          end
          @uniq_event_ids.push(donation.event_id) unless @uniq_event_ids.include?(donation.event_id)
        end
      end
      # Following condition is to search the array by name 
      if params[:search] 
        @searched_subordinates=[]
        @subordinates.each do |sub|
          full_name = sub.first_name + " " + sub.last_name
          if (full_name.downcase.include? params[:search].downcase) || (sub.phone_no.include? params[:search])
            @searched_subordinates.push sub
          end
        end
        @subordinates= Kaminari.paginate_array(@searched_subordinates).page(params[:page]).per(MadConstants.results_per_page)
      else
        @subordinates= Kaminari.paginate_array(@subordinates).page(params[:page]).per(MadConstants.results_per_page)
      end
    rescue Exception => exception
      puts exception.to_s
      return
    end
    respond_to { |format| format.html { render action: 'show' } }
  end

  # This function lets the Events Head or Finance Fellow to edit donation details. The Events Head can edit the donor details. 
  #     The Finance Fellow can edit that plus the donation amount. FF can also just delete the donation.
  # http://localhost:3000/events_donation_approvals/edit_donation/4
  def edit_donation
    @donation = EventDonation.find(params[:donation_id])
    @donation_id = params[:donation_id]
    @donor = @donation.donour
    old_donation_donor_name = @donor.first_name + " " + @donor.last_name
    old_donation_amount = @donation.donation_amount.to_s

    if (params[:commit])
      # If the email or phone has changed, make it a new donor.
      if(@donor.email_id != params[:email_id] or @donor.phone_no != params[:phone_no])
        @donor = Donour.new
        @donor.assign_attributes({
              :first_name => params[:first_name],
              :last_name => params[:last_name],
              :email_id => params[:email_id],
              :phone_no => params[:phone_no],
              :address => params[:address]
            })

      else
        @donor.assign_attributes({
          :first_name => params[:first_name],
          :last_name => params[:last_name],
          :address => params[:address]
        })
      end


      if @donor.save
        # Change the existing donor to the new donor
        @donation.assign_attributes({
          :donour_id => @donor.id,
          # :updated_by => session[:session_user] # If activated, this will hinder the grouping by subodinate function.
        })
        if(params[:donation_amount])
          if User.has_role Role.CITY_FINANCIAL_CONTROLLER,session[:roles]
            @donation.assign_attributes({:donation_amount => params[:donation_amount]})
          end
        end
        @donation.save

        #Send SMS to Fundraiser that the donation was modified. #:TODO:
        fundraiser = User.find(@donation.fundraiser_id)
        editor = User.find(session[:session_user])
        sms_message = "The donation donuted by you ("+old_donation_donor_name+", "+old_donation_amount+") has been changed (" \
            + @donor.first_name+" "+ @donor.last_name + ", " + @donation.donation_amount.to_s + ") by " \
            + editor.first_name + " " + editor.last_name
        # Template: The donation donuted by you(^name1^, ^amount1^) has been changed(^name2^, ^amount2^) by ^name3^
        #           The donation donuted by you (123,123) has been changed (123,123) by 123
        send_sms(fundraiser.phone_no, sms_message)

        flash[:success] = "Edited the details of the Donation ID: " + params[:donation_id]
        redirect_to action: "show"
      else
        flash[:error] = "Error Saving Donor details."
      end
    end
  end

  def update
    @approver = User.new
    @approver.set_current_user_role_map session[:roles]
    donation_status_by_role = EventDonation.get_approval_status_by_role @approver.current_role
    is_finance_fellow = false
    if User.has_role Role.CITY_FINANCIAL_CONTROLLER,session[:roles]
      is_finance_fellow = true
    end
    
    if donation_approval_params[:approve_all]
      subordinate=User.find params[:subordinate_id]
      subordinate.transaction do
        begin
          subordinate.event_donations.each do |donation|
            approve donation,donation_status_by_role[:current_status],donation_status_by_role[:post_approval_status]
            
            if is_finance_fellow
            	# send confirmation mail and SMS
             	send_confirmation_notification(donation)
            end
          end
        rescue ActiveRecord::Rollback
          respond_to do |format|
            format.js {  render :json => subordinate.id.to_s , :status => 500}
          end
        end
        respond_to do |format|
          format.js {  render :json => subordinate.id.to_s,:status => 200}
        end
      end
    else
      begin
        donation = EventDonation.find donation_approval_params[:donation_id]
      rescue ActiveRecord::RecordNotFound
        respond_to do |format|
          format.js {  render :json => donation.id.to_s , :status => 500}
        end
      end
      begin
        approve donation,donation_status_by_role[:current_status],donation_status_by_role[:post_approval_status]
        if is_finance_fellow
        	# send confirmation mail and SMS
        	send_confirmation_notification(donation)
        end
      rescue ActiveRecord::Rollback
        respond_to do |format|
          format.js {  render :json => donation.id.to_s , :status => 500}
        end
      end
      respond_to do |format|
        format.js {  render :json => donation.id.to_s,:status => 200}
      end
    end
  end
  
  def send_confirmation_notification(donation)
    donour = Donour.find(donation.donour_id)

    if donour.present?
      product_or_event_name = ''
      event = Event.find(donation.event_id) 
      if event.present?
        product_or_event_name = event.event_name
      else
        product_or_event_name = 'General Donation'
      end
      donour_name = donour.first_name
      if donour.last_name.present?
        donour_name += ' ' + donour.last_name
      end
      
      begin  
        event_confirmation_sms(donour_name, 
                      donation.donation_amount.to_s, 
                      donour.phone_no.to_s,product_or_event_name)
      rescue
        #puts " alert msg sms not sent***************************"
      end                
      if donour.email_id.present?
        begin          
          email_text = confirmation_mail_template_for_event(donour_name, donour.email_id,
                                                     donation.donation_amount.to_s, 
                                                     donation.id.to_s, 
                                                     product_or_event_name)
    
          send_mails( donour.email_id , 'Donation Confirmation', email_text)
        rescue
          # alert msg email not sent
        end
      end 
    end
  end
  
  private

  def approve(donation,current_status,post_approval_status)
    if donation.donation_status == current_status
      donation.change_status params[:manager_id], post_approval_status
    end
  end

  def validate_user_role
    validate_user *EventsDonationApprovalsController.permitted_roles, session[:roles], MadConstants.home_page
  end

  def donation_approval_params
    params.permit(:id,:donation_id,:manager_id,:utf8,:_method,:volunteer_id,:approve_all,:commit)
  end
end
