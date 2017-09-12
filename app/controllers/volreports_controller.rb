class VolreportsController < ApplicationController
  
  before_filter :validate_user_role, :reset_date_range, :except => :report
  @permitted_roles = [Role.VOLUNTEER]
  class << self; attr_reader :permitted_roles end
  
  helper_method :sort_column, :sort_direction
    
  # -> Method generates a new date from field name and params
  # -> Generated date object is returned
  def build_date_from_params(field_name, params)
    Date.new(params["#{field_name.to_s}(1i)"].to_i, params["#{field_name.to_s}(2i)"].to_i, params["#{field_name.to_s}(3i)"].to_i)   
  end
  
  # -> Method takes a date in the format: Year-Month-Day
  # -> Returns a date object
  def build_date_from_date_string(date_string)
    if date_string.present?
      date_array = date_string.split('-').map{|date_str| date_str.to_i}
      Date.new(*date_array) # Flatten the array and pass to Date.new
    end
  end
  
  # ************** To export the tabel report as Excel format *******************
  # This function will get called from view link_to to render the format as excel.
  # For this we have defined a excel template @ /views/nationalcfrreports/index.xls.erb
  # Please refere this "http://railscasts.com/episodes/362-exporting-csv-and-excel?view=asciicast" to know
  # more about export table as excel
  def report
    filename = "volunteer_report_from_"+session[:from_date_range].to_s+"_to_"+session[:to_date_range].to_s+".xls"
    @report_donations = Donation.joins(:donour).where("donations.fundraiser_id = ? AND donations.created_at >= ? AND donations.created_at <= ?",  
          session[:session_user], session[:from_date_range].to_s+" "+$start_time, session[:to_date_range].to_s+" "+$end_time)
    respond_to do |format|
        format.xls { headers["Content-Disposition"] = "attachment; filename=\"#{filename}\"" }
    end
  end 
  
  def show
    @start_date_str = params[:from_date].to_s
    @start_date_str = @start_date_str.slice(@start_date_str.rindex("=>").to_i + 3, 10)
    
    @to_date_str = params[:to_date].to_s
    @to_date_str = @to_date_str.slice(@to_date_str.rindex("=>").to_i + 3, 10)
    
    @from_date_value = build_date_from_date_string(@start_date_str)   
    @to_date_value = build_date_from_date_string(@to_date_str)
    
    if @to_date_str == "\"}" || @start_date_str == "\"}"
      @donations = sort_column
      flash[:error] = "Date range required"
      flash[:alert] = ""
      generate_report_message(0,"","")
    elsif @to_date_str.present? && @start_date_str.present? && Date.parse(@to_date_str) < Date.parse(@start_date_str)
      @donations = sort_column
      flash[:error] = "Invalid Date Range"
      flash[:alert] = ""
      generate_report_message(0,"","")
    else
      flash[:alert] = ""
      flash[:error] = ""
      if params[:from_date].present? && params[:to_date].present?
        session[:from_date_range] = @from_date_value
        session[:to_date_range] = @to_date_value
      end
      @donations = sort_column
      donation_length = @donations.length
      if donation_length == 0
        if params[:from_date].present? && params[:to_date].present?
          generate_report_message(0,"","")
          flash[:alert] = "No report found for provided date range"
        end
      else
        generate_report_message(donation_length,@from_date_value,@to_date_value)
      end
    end
    @from_date_range = session[:from_date_range]
    @to_date_range = session[:to_date_range]
  end
  
  def sort_column
    @sort_field = ''
    if params[:sort].to_s == MadConstants.donor_name
      @sort_field = 'donours.first_name '
    elsif params[:sort].to_s == MadConstants.amount_donated
      @sort_field = 'donations.donation_amount'
    elsif params[:sort].to_s == MadConstants.receipt_status
      @sort_field = 'donations.donation_status'
    elsif params[:sort].to_s == MadConstants.phone_no
      @sort_field = 'donours.phone_no'
    elsif params[:sort].to_s == MadConstants.email_id
      @sort_field = 'donours.email_id'
    elsif params[:sort].to_s == MadConstants.date
      @sort_field = 'donations.created_at'
    else
      @sort_field = 'donations.id'      
    end
    
    if session[:from_date_range].present? && session[:to_date_range].present?
      Donation.joins(:donour).where("donations.fundraiser_id = ? AND donations.created_at >= ? AND donations.created_at <= ?",  session[:session_user], session[:from_date_range].to_s+" "+$start_time, session[:to_date_range].to_s+" "+$end_time).
        order(@sort_field + ' ' + sort_direction).paginate(:per_page => 10, :page => params[:page])
    else
      Donation.joins(:donour).where("donations.fundraiser_id = ?", session[:session_user]).order(@sort_field + ' ' + sort_direction).paginate(:per_page => 10, :page => params[:page])    
    end
  end
  
  def sort_direction
    %w[asc desc].include?(params[:direction]) ? params[:direction] : "asc"
  end
  
  def generate_report_message(donation_length,from_date,to_date)
    if donation_length == 0
      @report_message = ""
    else
      @report_message = "Showing report from "+from_date.to_s+" to "+to_date.to_s
    end    
  end
  
  private
  def validate_user_role
    validate_vol_user *VolreportsController.permitted_roles, session[:roles], MadConstants.home_page
  end
  
  def validate_vol_user(*permitted_roles,user_role_list,redirection_page)
    permitted_roles.each do |role|
      if(User.has_role(role,user_role_list))
        return
      end
    end
    redirect_to redirection_page, :flash => {:info => MadConstants.permission_denied}
  end 
    
  
  private 
  def reset_date_range
    session[:from_date_range] = ''
    session[:to_date_range] = ''
  end
end
