$start_time = "00:00:00"
$end_time = "23:59:59"
class NationaltallyreportsController < ApplicationController
  
  before_filter :validate_user_role, :reset_date_range, :except => :report
  @permitted_roles = [Role.NATIONAL_CFR_HEAD, Role.ADMINISTRATOR]
  class << self; attr_reader :permitted_roles end
  attr_accessor :from_date, :to_date
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
  # For this we have defined a excel template @ /views/nationaltallyreports/index.xls.erb
  # Please refere this "http://railscasts.com/episodes/362-exporting-csv-and-excel?view=asciicast" to know
  # more about export table as excel
  def report

    filename = "nationaltally_report_from_"+session[:from_date_range_national_tally].to_s+"_to_"+session[:to_date_range_national_tally].to_s+".xls"
    @report_donations = Donation.joins(:donour).joins('inner join users as users on users.id = donations.fundraiser_id').
             joins('inner join cities as cities on cities.id = users.city_id').
            where("(donations.donation_status = 'RECEIPT SENT' OR donations.donation_status = 'DEPOSIT COMPLETE') AND donations.created_at >= ? AND donations.created_at <= ?",  
           session[:from_date_range_national_tally].to_s+" "+$start_time, session[:to_date_range_national_tally].to_s+" "+$end_time)

    respond_to do |format|
      format.xls { headers["Content-Disposition"] = "attachment; filename=\"#{filename}\"" }
    end
  end 
  
  
  def show
  	unless params[:from_date] or params[:to_date]
  		flash[:alert] = ""
      flash[:error] = "Date range required"
      @donations = nil
      generate_report_message(0,"","")
  	end
	
    @start_date_str = params[:from_date].to_s
    @start_date_str = @start_date_str.slice(@start_date_str.rindex("=>").to_i + 3, 10)
    
    @to_date_str = params[:to_date].to_s
    @to_date_str = @to_date_str.slice(@to_date_str.rindex("=>").to_i + 3, 10)
    
    @from_date_value = build_date_from_date_string(@start_date_str)   
    @to_date_value = build_date_from_date_string(@to_date_str)
    
    if @to_date_str == "\"}" || @start_date_str == "\"}"
      flash[:alert] = ""
      flash[:error] = "Date range required"
      @donations = nil
      generate_report_message(0,"","")

    elsif @to_date_str.present? && @start_date_str.present? && Date.parse(@to_date_str) < Date.parse(@start_date_str)
      @donations = nil
      flash[:alert] = ""
      flash[:error] = "Invalid Date Range"
      generate_report_message(0,"","")
      
    else
      flash[:alert] = ""
      flash[:error] = ""
      if params[:from_date].present? && params[:to_date].present?
        session[:from_date_range_national_tally] = @from_date_value
        session[:to_date_range_national_tally] = @to_date_value

        generate_report_message(1,@from_date_value,@to_date_value)
        
            
        from_date = session[:from_date_range_national_tally]
        to_date = session[:to_date_range_national_tally]

      else
        flash[:alert] = ""
        flash[:error] = "Date range required"
        @donations = nil
        generate_report_message(0,"","")
      end
    end
  
  end
  
    
  def generate_report_message(donation_length,from_date,to_date)
    if donation_length == 0
      @report_message = ""
    else
      @report_message = "Click to export reports from "+from_date.to_s+" to "+to_date.to_s
    end    
  end
  
  private
  def validate_user_role
    validate_user *NationaltallyreportsController.permitted_roles, session[:roles], MadConstants.home_page
  end
  
  private 
  def reset_date_range
    session[:from_date_range_national_tally] = ''
    session[:to_date_range_national_tally] = ''
  end
end
