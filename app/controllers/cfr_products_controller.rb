class CfrProductsController < ApplicationController

  before_filter :authenticate_user!
  before_filter :validate_user_role
  before_action :set_cfr_product, only: [:show, :edit, :update, :destroy]
  @permitted_roles = [Role.CFR_FELLOW,
                      Role.NATIONAL_CFR_HEAD,
                      Role.CITY_PRESIDENT]
  class << self; attr_reader :permitted_roles end

  # GET /cfr_products
  # GET /cfr_products.json
  def index
    flash[:error]=""
    flash[:alert]=""
    if params[:search]
      @cfr_products = CfrProduct.where(:is_other_product => '1').where(:city_id => City.select(:id).where("name LIKE ?", "%#{params[:search]}%"))
      products_count = @cfr_products.length
      if products_count < 1
        flash[:alert] = "No Product found"
      end
    else
      @cfr_products = CfrProduct.where(:is_other_product => '1')      
    end
  end

  # GET /cfr_products/1
  # GET /cfr_products/1.json
  def show
    @cfr_city = City.find(@cfr_product[:city_id])
  end

  # GET /cfr_products/new
  def new
    @cfr_product = CfrProduct.new
  end

  # GET /cfr_products/1/edit
  def edit
  end

  # POST /cfr_products
  # POST /cfr_products.json
  def create
    @cfr_product = CfrProduct.new(cfr_product_params)
    @cfr_product.assign_attributes(:is_other_product => 'true')
    respond_to do |format|
      if @cfr_product.save
        format.html { redirect_to @cfr_product, notice: 'Cfr product was successfully created.' }
        format.json { render action: 'show', status: :created, location: @cfr_product }
      else
        format.html { render action: 'new' }
        format.json { render json: @cfr_product.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /cfr_products/1
  # PATCH/PUT /cfr_products/1.json
  def update
    respond_to do |format|
      if @cfr_product.update(cfr_product_params)
        format.html { redirect_to @cfr_product, notice: 'Cfr product was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @cfr_product.errors, status: :unprocessable_entity }
      end
    end
  end
  
  
  
  # DELETE /cfr_products/1
  # DELETE /cfr_products/1.json
  def destroy
    @donation = Donation.find_by_product_id(@cfr_product.id)
    
    if @donation.present?
      flash[:error] = 'This Cfr product is associated with some donations. It can not be deleted.'
    else
      @cfr_product.destroy
      flash[:alert] = 'Cfr product is deleted successfully.'
    end
    
    respond_to do |format|
      format.html { redirect_to cfr_products_url }
      format.json { head :no_content }
    end  
  end

  private
  def validate_user_role
    validate_user *CfrProductsController.permitted_roles, session[:roles], MadConstants.home_page
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_cfr_product
    @cfr_product = CfrProduct.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def cfr_product_params
    params.require(:cfr_product).permit(:name, :description, :target, :start_date, :end_date, :city_id, :image_logo)
  end
end
