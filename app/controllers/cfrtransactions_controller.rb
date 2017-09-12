class CfrtransactionsController < ApplicationController
  helper_method :sort_column, :sort_direction
  
  before_filter :authenticate_user!
  before_filter :validate_user_role

  @permitted_roles = [Role.ADMINISTRATOR,
                      Role.CFR_FELLOW,
                      Role.NATIONAL_CFR_HEAD,
                      Role.CITY_PRESIDENT]

  class << self; attr_reader :permitted_roles end
  
  # GET /cfrtransactions
  # GET /cfrtransactions.json
  def index
    flash[:error]=""
    flash[:alert]=""
    @donations = sort_column
  end

  # GET /cfrtransactions/1
  # GET /cfrtransactions/1.json
  def show
    flash[:error]=""
    flash[:alert]=""
    @donations = sort_column
    donation_count = @donations.length
    if donation_count < 1
      flash[:alert] = "No transaction found"
    end
  end

  # GET /cfrtransactions/new
  def new

  end

  # GET /cfrtransactions/1/edit
  def edit
    redirect_user_404
  end

  # POST /donations
  # POST /donations.json
  def create

  end

  # PATCH/PUT /donations/1
  # PATCH/PUT /donations/1.json
  def update

  end

  # DELETE /donations/1
  # DELETE /donations/1.json
  def destroy

  end
  
  # Helper method for pagination and sorting
  def sort_column
      
    @sort_field = ''
    if params[:sort].to_s == MadConstants.donor_name
      @sort_field = 'concat(donours.first_name,donours.last_name)'
    elsif params[:sort].to_s == MadConstants.donation_amount
      @sort_field = 'donations.donation_amount'
    elsif params[:sort].to_s == MadConstants.donation_type
      @sort_field = 'donations.donation_type'
    elsif params[:sort].to_s == MadConstants.product
      @sort_field = 'cfr_products.name'
    elsif params[:sort].to_s == MadConstants.fundraiser_name
      @sort_field = 'users.first_name'
    elsif params[:sort].to_s == MadConstants.donation_status
      @sort_field = 'donations.donation_status'
    elsif params[:sort].to_s == MadConstants.eighty_g_required
      @sort_field = 'donations.eighty_g_required'
    else
      @sort_field = 'donations.id'      
    end
    
    Donation.joins(:donour).joins('inner join cfr_products as cfr_products on cfr_products.id = donations.product_id').
        joins('inner join users as users on users.id = donations.fundraiser_id').
        cfr_txn_search(params[:search]).order(@sort_field + ' ' + sort_direction).
        paginate(:per_page => 10, :page => params[:page])
  end
  
  # Helper method for pagination and sorting
  def sort_direction
    %w[asc desc].include?(params[:direction]) ? params[:direction] : "asc"
  end
  
  private
  def validate_user_role
    validate_user *CfrtransactionsController.permitted_roles, session[:roles], MadConstants.home_page
  end

  # Use callbacks to share common setup or constraints between actions.

  # Never trust parameters from the scary internet, only allow the white list through.
  def donation_params
    params.permit(:all)
  end
end
