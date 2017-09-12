class HomesController < ApplicationController
  before_filter :authenticate_user!
  before_action only: [:show, :edit, :update, :destroy]

  # GET /homes
  # GET /homes.json
  def index
    flash[:error]=""
    flash[:alert]=""
    @is_admin= false
    if User.has_role Role.ADMINISTRATOR,session[:roles]
      @is_admin=true
    end
  end

  # GET /homes/1
  # GET /homes/1.json
  def show
    redirect_to MadConstants.home_page
  end

  # GET /homes/new
  def new
    redirect_to MadConstants.home_page
  end

  # GET /homes/1/edit
  def edit
    redirect_to MadConstants.home_page
  end

  # POST /homes
  # POST /homes.json
  def create

  end

  # PATCH/PUT /homes/1
  # PATCH/PUT /homes/1.json
  def update

  end

  # DELETE /homes/1
  # DELETE /homes/1.json
  def destroy

  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_home

  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def home_params
    params[:home]
  end
end
