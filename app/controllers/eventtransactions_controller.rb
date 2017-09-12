class EventtransactionsController < ApplicationController
  helper_method :sort_column, :sort_direction
  
  before_filter :authenticate_user!
  before_filter :validate_user_role
  @permitted_roles = [Role.ADMINISTRATOR,
                      Role.EVENTS_FELLOW,
                      Role.CITY_PRESIDENT,
                      Role.NATIONAL_EVENTS_HEAD]
  class << self; attr_reader :permitted_roles end
  
  def index
    @event_transactions = sort_column
  end

  def show
    @event_transactions = sort_column
  end

  def sort_column
    @sort_field = ''
    puts params[:sort]
    if params[:sort].to_s == MadConstants.event_name
      @sort_field = 'events.event_name '
    elsif params[:sort].to_s == MadConstants.donor_name
      @sort_field = 'donours.first_name '
    elsif params[:sort].to_s == MadConstants.donation_amount
      @sort_field = 'event_donations.donation_amount'
    elsif params[:sort].to_s == MadConstants.fundraiser_name
      @sort_field = 'users.first_name'
    elsif params[:sort].to_s == MadConstants.donation_status
      @sort_field = 'event_donations.donation_status'
    else
      @sort_field = 'event_donations.id'      
    end
    
    EventDonation.joins(:donour).joins(:event).
        joins('inner join users as users on users.id = event_donations.fundraiser_id').
        event_txn_search(params[:search]).order(@sort_field + ' ' + sort_direction).
        paginate(:per_page => 10, :page => params[:page])
  end
  
  def sort_direction
    %w[asc desc].include?(params[:direction]) ? params[:direction] : "asc"
  end
  
  private
  def validate_user_role
    validate_user *EventtransactionsController.permitted_roles, session[:roles], MadConstants.home_page
  end
  
  # Never trust parameters from the scary internet, only allow the white list through.
  def event_transaction_params
    params.permit(:all)
  end
end

