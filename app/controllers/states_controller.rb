class StatesController < ApplicationController
  before_filter :authenticate_user!
  before_filter :validate_user_role
  before_action :set_state, only: [:show, :edit, :update, :destroy]

  # GET /states
  # GET /states.json
  def index
    @states = State.all.order(:name)
  end

  # GET /states/1
  # GET /states/1.json
  def show
  end

  # GET /states/new
  def new
    @state = State.new
  end

  # GET /states/1/edit
  def edit
  end

  # POST /states
  # POST /states.json
  def create
    
      @state = State.new(:name => state_params[:name].strip)
      respond_to do |format|
        if @state.save
          format.html { redirect_to @state, notice: 'State was successfully created.' }
          format.json { render action: 'show', status: :created, location: @state }
        else
          format.html { render action: 'new' }
          format.json { render json: @state.errors, status: :unprocessable_entity }
        end
      end
  end

  # PATCH/PUT /states/1
  # PATCH/PUT /states/1.json
  def update
    respond_to do |format|
     
        if @state.update(:name => state_params[:name].strip)
          format.html { redirect_to @state, notice: 'State was successfully updated.' }
          format.json { head :no_content }
        else
          format.html { render action: 'edit' }
          format.json { render json: @state.errors, status: :unprocessable_entity }
        end
      end
  end

  # DELETE /states/1
  # DELETE /states/1.json
  def destroy
    @state.destroy
    respond_to do |format|
      format.html { redirect_to states_url }
      format.json { head :no_content }
    end
  end

  private

  def validate_user_role
    validate_user session[:roles],MadConstants.home_page
  end
  # Use callbacks to share common setup or constraints between actions.
  def set_state
    @state = State.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def state_params
    params.require(:state).permit(:name)
  end
end
