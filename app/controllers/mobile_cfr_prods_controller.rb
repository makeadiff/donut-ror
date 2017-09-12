class MobileCfrProdsController < ActionController::Base
  @basicauth = BasicAuth.find(:first)
  
  http_basic_authenticate_with :name => @basicauth.name, :password => @basicauth.password
  skip_before_filter :verify_authenticity_token
  
  before_action :set_mobile_cfr_prod, only: [:show, :edit, :update, :destroy]

  # GET /mobile_cfr_prods
  # GET /mobile_cfr_prods.json
  def index
    @mobile_cfr_prods = CfrProduct.all
  end
  
  def cfrproducts
    @cfr_products = CfrProduct.where(:city_id => User.select("city_id").where(:id => params[:volunteer_id]))
     
    respond_to do |format|
      format.xml # COMMENT THIS OUT TO USE YOUR CUSTOM XML RESPONSE INSTEAD  { render :xml => @capital_city }
    end
  end
  
  # GET /mobile_cfr_prods/1
  # GET /mobile_cfr_prods/1.json
  def show
    format.xml {
      render :xml# => @mobile_cfr_prods.to_xml
    }
  end

  # GET /mobile_cfr_prods/new
  def new
    @mobile_cfr_prod = CfrProduct.new
  end

  # GET /mobile_cfr_prods/1/edit
  def edit
  end

  # POST /mobile_cfr_prods
  # POST /mobile_cfr_prods.json
  def create
    @mobile_cfr_prods = CfrProduct.where(:city_id => mobile_cfr_prod_params[:city_id]).find(:all)
    respond_to do |format|
      if @mobile_cfr_prods.nil?
        format.html { render action: 'show' }
        format.xml# { render json: @mobile_cfr_prods.errors, status: :unprocessable_entity }
      else
        format.xml# { render :xml => @mobile_cfr_prods.to_xml }
      end
    end
    
    
    # @mobile_cfr_prod = CfrProduct.new(mobile_cfr_prod_params)
# 
    # respond_to do |format|
      # if @mobile_cfr_prod.save
        # format.html { redirect_to @mobile_cfr_prod, notice: 'Mobile cfr prod was successfully created.' }
        # format.json { render action: 'show', status: :created, location: @mobile_cfr_prod }
      # else
        # format.html { render action: 'new' }
        # format.json { render json: @mobile_cfr_prod.errors, status: :unprocessable_entity }
      # end
    # end
  end

  # PATCH/PUT /mobile_cfr_prods/1
  # PATCH/PUT /mobile_cfr_prods/1.json
  def update
    respond_to do |format|
      if @mobile_cfr_prod.update(mobile_cfr_prod_params)
        format.html { redirect_to @mobile_cfr_prod, notice: 'Mobile cfr prod was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @mobile_cfr_prod.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /mobile_cfr_prods/1
  # DELETE /mobile_cfr_prods/1.json
  def destroy
    @mobile_cfr_prod.destroy
    respond_to do |format|
      format.html { redirect_to mobile_cfr_prods_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_mobile_cfr_prod
      @mobile_cfr_prod = CfrProduct.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def mobile_cfr_prod_params
      params.permit(:city_id, :volunteer_id)
    end
end
