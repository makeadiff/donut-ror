class DonationApprovalController < ApplicationController
  include SmsHelper
  include EmailHelper
  include EmailTemplateHelper
  include NumbertowordHelper
  
  before_filter :validate_user_role

  @permitted_roles = [Role.NATIONAL_FINANCIAL_CONTROLLER,
                      Role.CFR_POC,
                      Role.CITY_FINANCIAL_CONTROLLER]
                      
  class << self; attr_reader :permitted_roles end

  def show
    flash[:error]=""
    flash[:alert]=""
    begin
      @approver= User.find(session[:session_user]) if @approver.nil?
      @approver.set_current_user_role_map session[:roles]
      donation_status_by_role = Donation.get_approval_status_by_role @approver.current_role
      @subordinates=[]
      @approver.subordinates.each do |subordinate|
        total_amount_of_donations=subordinate.total_amount_of_donations(donation_status_by_role[:current_status])
        unless total_amount_of_donations == 0
          subordinate.total_donation_amount =  total_amount_of_donations
          @subordinates.push subordinate
        end
      end
      
      # Following condition is to serach the array by name 
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

  # This function lets the POC or FC to edit donation details. The POC can edit the donor details. 
  #     The FC can edit that plus the donation amount. FC can also just delete the donation.
  # http://localhost:3000/donation_approval/edit_donation/10163
  # POC:  9191919190/pass    #3152
  # FC:   9999350812/pass    #2973
  def edit_donation
    @donation = Donation.find(params[:donation_id])
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

  # Delete a donation. Only City Finance Fellow can do this.
  def delete
    if User.has_role Role.CITY_FINANCIAL_CONTROLLER,session[:roles]
      donation = Donation.find(params[:donation_id])

      deleted = DeletedDonation.new
      deleted.assign_attributes({
        :id => donation.id,
        :donation_type => donation.donation_type,
        :version => donation.version,
        :fundraiser_id => donation.fundraiser_id,
        :donour_id => donation.donour_id,
        :source_id => donation.source_id,
        :donation_status => donation.donation_status,
        :eighty_g_required => donation.eighty_g_required,
        :product_id => donation.product_id,
        :donation_amount => donation.donation_amount,
        :updated_by => session[:session_user],
        :created_at => donation.created_at,
        :updated_at => Time.now})

      # if !deleted.save
      #   flash[:error] = "Backup couldn't be saved."
      # end

      fundraiser = User.find(donation.fundraiser_id)
      editor = User.find(session[:session_user])
      sms_message = "The donation donuted by you of Rs " + donation.donation_amount.to_s + " from " \
        + donation.donour.first_name + " " + donation.donour.last_name + " has been deleted by " + editor.first_name + " " + editor.last_name
      # Template: The donation donuted by you of Rs ^amount^ from ^name1^ has been deleted by ^name2^
      #           The donation donuted by you of Rs 123 from 123 has been deleted by 123
      send_sms(fundraiser.phone_no, sms_message)

      donation.destroy
      flash[:success] = "Donation of " + donation.donation_amount.to_s + " Rs deleted."
    else
      flash[:error] = "You don't have the necessary privilages to delete the donation"
    end

    redirect_to action: "show"
  end

  def update
    @approver = User.new
    @approver.set_current_user_role_map session[:roles]
    donation_status_by_role = Donation.get_approval_status_by_role @approver.current_role
    isNFC, isCFRPOC, isCFC = false, false, false
    
    if User.has_role Role.NATIONAL_FINANCIAL_CONTROLLER,session[:roles]
      isNFC = true
    elsif User.has_role Role.CFR_POC,session[:roles]
      isCFRPOC = true
    else 
      isCFC = true
    end

    if donation_approval_params[:approve_all]
      subordinate=User.find params[:subordinate_id]
      subordinate.transaction do
        begin
          subordinate.donations.each do |donation|
            if isNFC && donation.eighty_g_required
              approve donation,donation_status_by_role[:current_status],Donation.STATUS_EIGHTY_G_RECEIPT_PENDING
            else
              approve donation,donation_status_by_role[:current_status],donation_status_by_role[:post_approval_status]
            end
            
            if isCFC
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
        donation = Donation.find donation_approval_params[:donation_id]
      rescue ActiveRecord::RecordNotFound
        respond_to do |format|
          format.js {  render :json => donation.id.to_s , :status => 500}
        end
      end
      begin

        if isNFC && donation.eighty_g_required
          approve donation,donation_status_by_role[:current_status],Donation.STATUS_EIGHTY_G_RECEIPT_PENDING
        else
          approve donation,donation_status_by_role[:current_status],donation_status_by_role[:post_approval_status]
        end
        if isCFC
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

  # This is to manually trigger a donation recipt to be sent for the donation who's ID is given as the parameter.
  # Will show a template missing error. 
  def send_receipt
    donation = Donation.find params[:donation_id]
    send_confirmation_notification(donation, true)

    render body: "Done"
  end
  
  def send_confirmation_notification(donation, force_send=false)
    donour = Donour.find(donation.donour_id)
    if donour.present?
      product_or_event_name = ''
      don_product = CfrProduct.where(:is_other_product => 1, :id => donation.product_id) 
      if don_product.present?
        product_or_event_name = don_product.name
      else
        product_or_event_name = 'General Donation'
      end
      donour_name = donour.first_name
      if donour.last_name.present?
        donour_name += ' ' + donour.last_name
      end
      
      if donour.email_id.present?
        begin
          # puts donation.inspect

          if donation.eighty_g_required.to_s == 'true' and force_send == false
            # Nothing, right now.
          else
            # puts "Will try to send the email"
            begin
              send_confirmation_sms(donour_name, donation.donation_amount.to_s, donour.phone_no.to_s)
            rescue
              # alert message sms not sent
              puts "SMS Could not be sent."
            end

            session[:donor_name] = donour_name
            session[:donation_amount] = donation.donation_amount.to_s
            session[:don_id] = donation.id.to_s
            session[:donor_address] = donour.address.to_s
            session[:created_at] = donation.created_at.day.to_s + "/" + donation.created_at.mon.to_s + "/" + donation.created_at.year.to_s

            number = donation.donation_amount.to_s
            amt_parts = number.to_s.split(".")
            
            dec_result = amt_parts.count > 1 ? amt_parts[1].to_s : 0
            amt_rupees_text = "#{wordify number.to_i}"
            amt_paise_text = nil
            begin
              if dec_result.to_i > 0
                amt_paise_text = "#{wordify dec_result.to_i}" + ' paise'
              end
            rescue 
              amt_paise_text = nil
            end
            if amt_paise_text.nil?
              session[:donation_amount_text] = amt_rupees_text + ' rupees'
            else
              session[:donation_amount_text] = amt_rupees_text + ' rupees and ' + amt_paise_text
            end
            
            pdf_80g_reciept = WickedPdf.new.pdf_from_string(
              render_to_string('pdf_templates/don_receipt_non80g.pdf.erb')
            )
            
            email_text = confirmation_mail_template(donour_name, donour.email_id,
                                                     donation.donation_amount.to_s, 
                                                     donation.id.to_s, 
                                                     product_or_event_name)
           
            send_mails_with_attachment(donour.email_id, 'Donation Confirmation', email_text, pdf_80g_reciept, 'DonationReciept.pdf')
            session[:donor_name], session[:donation_amount], session[:don_id], session[:donation_amount_text], session[:donor_address] = ''
            
          end
        rescue Exception => ex
          logger.warn "Unable to send notification: #{ex}" 
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
    validate_user *DonationApprovalController.permitted_roles, session[:roles], MadConstants.home_page
  end

  def donation_approval_params
    params.permit(:id,:donation_id,:manager_id,:utf8,:_method,:volunteer_id,:approve_all)
  end
end
