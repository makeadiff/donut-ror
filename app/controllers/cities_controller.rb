class CitiesController < ApplicationController
  include EmailHelper
  include EmailTemplateHelper
  
  helper_method :sort_column, :sort_direction
  
  before_filter :authenticate_user!
  before_filter :validate_user_role
  before_action :set_city, only: [:show, :edit, :update, :destroy]

  # GET /cities
  # GET /cities.json
  def index
    flash[:error]=""
    flash[:alert]=""
    @cities = sort_column#City.all.order(:name)
  end

  # GET /cities/1
  # GET /cities/1.json
  def show
    @state =  State.find(@city.state_id)
  end

  # GET /cities/new
  def new
    @city = City.new
  end

  # GET /cities/1/edit
  def edit
  end

  # POST /cities
  # POST /cities.json
  def create
    @city = City.new(:name => city_params[:name].strip, :state_id => city_params[:state_id])
    respond_to do |format|
      if @city.save
        format.html { redirect_to @city, notice: 'City was successfully created.' }
        format.json { render action: 'show', status: :created, location: @city }
      else
        format.html { render action: 'new' }
        format.json { render json: @city.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /cities/1
  # PATCH/PUT /cities/1.json
  def update
    respond_to do |format|
      
      if @city.update(:name => city_params[:name].strip, :state_id => city_params[:state_id])
        format.html { redirect_to @city, notice: 'City was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @city.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /cities/1
  # DELETE /cities/1.json
  def destroy
    @city.destroy
    respond_to do |format|
      format.html { redirect_to cities_url }
      format.json { head :no_content }
    end
  end

  private
  def validate_user_role
     validate_user session[:roles],MadConstants.home_page
  end
  # Use callbacks to share common setup or constraints between actions.
  def set_city
    @city = City.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def city_params
    params.require(:city).permit(:name, :state_id)
  end
  
  def sort_column
    begin
      @sort_field = ''
      if params[:sort].to_s == 'Region'
        @sort_field = 'states.name '
      else
        @sort_field = 'cities.name'
      end
      City.select("DISTINCT cities.*").joins(:state).order(@sort_field + ' ' + sort_direction).paginate(:per_page => 15, :page => params[:page])
    rescue Exception => e
      logger.warn "**********************Unable to Sort : #{e}"
    end
        
  end
  
  def sort_direction
    %w[asc desc].include?(params[:direction]) ? params[:direction] : "asc"
  end
end
