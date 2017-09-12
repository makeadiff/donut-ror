# This controller is an example of pagination in which table column sorting and searching also provided.
# For this type of implementation we used here **gem "will_paginate", "~> 3.0.4"** this gem.
# And the implementation is refered from following addresses
#  1. -->   http://railscasts.com/episodes/240-search-sort-paginate-with-ajax?view=asciicast
#  2. -->   http://railscasts.com/episodes/228-sortable-table-columns
class EightyGApprovalController < ApplicationController
  include EmailHelper
  include EmailTemplateHelper
  include NumbertowordHelper
  
  before_filter :validate_user_role
  
  @permitted_roles =[Role.NATIONAL_FINANCIAL_CONTROLLER]
  class << self; attr_reader :permitted_roles end
  
  helper_method :sort_column, :sort_direction
  
  # -> Method initializes instance variable @donations
  #    which holds all donations which require 80g
  def show
  	if params[:commit] == "Send All"
  		puts "Send all repipts..."
      donation_pending = Donation.where(:eighty_g_required => true,:donation_status => [Donation.STATUS_EIGHTY_G_RECEIPT_PENDING]).joins(:donour).search(params[:search])
      donation_pending.each { |don|
        puts "Email : " + don.donour.email_id
        # don.change_status params[:approver_id], Donation.STATUS_EIGHTY_G_RECEIPT_SENT
        self.send_eighty_g_reciept_notification(don)

        donation = Donation.find(don.id)
        if donation.donation_status == Donation.STATUS_EIGHTY_G_RECEIPT_PENDING
          donation.change_status params[:approver_id], Donation.STATUS_EIGHTY_G_RECEIPT_SENT
        end
      }
      redirect_to action: "emails_sent"
      return 
  	end

    @donations = sort_column
  end

  def emails_sent
    render "eighty_g_approval/emails_sent.html.erb"
  end
  
  def update
    donation = Donation.find(params[:donation_id])
    if donation.donation_status == Donation.STATUS_EIGHTY_G_RECEIPT_PENDING
      donation.change_status params[:approver_id], Donation.STATUS_EIGHTY_G_RECEIPT_SENT
      
      send_eighty_g_reciept_notification(donation)
    end
    respond_to do |format|
      format.js {  render :json => donation.id.to_s,:status => 200}
    end
  end 
  
  # -> Method sends 80g receipt mail and pdf
  def send_eighty_g_reciept_notification(donation)
    begin
      # send mail for 80g reciept
      donour = Donour.find(donation.donour_id)
      product = CfrProduct.where(:id => donation.product_id, :is_other_product => 1)
      product_or_event_name = ''
      if product.present?
        product_or_event_name = product.name.to_s
      else
        product_or_event_name = 'General Donation'
      end

      if donour.present?
        donour_name = donour.first_name
        if donour.last_name.present?
          donour_name += ' ' + donour.last_name
        end
        if donour.email_id.present?
          begin
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
              render_to_string('pdf_templates/don_receipt_80g.pdf.erb')
            )
            email_text = confirmation_mail_template_with_eighty_g(donour_name, donour.email_id,
                                                       donation.donation_amount.to_s, 
                                                       donation.id.to_s, 
                                                       product_or_event_name)
            puts "Emails " + donour.email_id
            send_mails_with_attachment(donour.email_id, 'Donation Confirmation', email_text, pdf_80g_reciept, 'DonationReciept.pdf')
            session[:donor_name], session[:donation_amount], session[:don_id], session[:donation_amount_text], session[:donor_address] = ''
            
          rescue Exception => e
            logger.warn "Unable to send mail: #{e}" 
          end
        end  
      end
    rescue Exception => ex
      logger.warn "Unable to send notification: #{ex}" 
    end 
  end
  
  private
  
  def sort_column
    @sort_field = ''
    puts params[:sort]
    if params[:sort].to_s == MadConstants.donor_name
      @sort_field = 'concat(donours.first_name,donours.last_name)'
    elsif params[:sort].to_s == MadConstants.donation_amount
      @sort_field = 'donations.donation_amount'
    elsif params[:sort].to_s == MadConstants.email_id
      @sort_field = 'donours.email_id'
    elsif params[:sort].to_s == MadConstants.phone_no
      @sort_field = 'donours.phone_no'
    elsif params[:sort].to_s == 'Donation Date'
      @sort_field = 'donations.created_at'
    elsif params[:sort].to_s == 'Status' || params[:sort].to_s == 'Approve'
      @sort_field = 'donations.donation_status'
    else
      @sort_field = 'donations.id'      
    end
    #@donations = Donation.where(:eighty_g_required => true,:donation_status => [Donation.STATUS_EIGHTY_G_RECEIPT_PENDING,Donation.STATUS_EIGHTY_G_RECEIPT_SENT]).search(params[:search]).order(sort_column + " " + sort_direction).paginate(:per_page => 5, :page => params[:page])
    Donation.where(:eighty_g_required => true,:donation_status => 
          [Donation.STATUS_EIGHTY_G_RECEIPT_PENDING,Donation.STATUS_EIGHTY_G_RECEIPT_SENT]).joins(:donour).search(params[:search]).order(@sort_field + ' ' + sort_direction).paginate(:per_page => 25, :page => params[:page])

   # Donation.column_names.include?(params[:sort]) ? params[:sort] : "donation_amount"
  end
  
  def sort_direction
    %w[asc desc].include?(params[:direction]) ? params[:direction] : "asc"
  end
  
  def validate_user_role
    validate_user *EightyGApprovalController.permitted_roles, session[:roles],MadConstants.home_page
  end
  
end
