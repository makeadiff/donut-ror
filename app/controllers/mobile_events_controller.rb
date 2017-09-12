class MobileEventsController < ActionController::Base
  @basicauth = BasicAuth.find(:first)
  
  http_basic_authenticate_with :name => @basicauth.name, :password => @basicauth.password
  skip_before_filter :verify_authenticity_token
  
  before_action :set_event, only: [:show]
  # GET /events
  # GET /events.json
  def index
    @events = Event.all
  end

  # GET /events/1
  # GET /events/1.json
  def show
    format.xml {
      render :xml
    }
  end
  
  def events
    @events = Event.where(:id => EventVolunteerMap.select("event_id").where(:volunteer_id => params[:volunteer_id]), :status => 1)

    respond_to do |format|
      format.xml # COMMENT THIS OUT TO USE YOUR CUSTOM XML RESPONSE INSTEAD  { render :xml => @capital_city }
    end
  end

  # GET /events/new
  def new
    @event = Event.new
    @volunteers = Array.new
    @cities = []
  end

  # POST /events
  # POST /events.json
  def create
    
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_event
      @event = Event.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def event_params
      params.permit(:volunteer_id, :event_name, :image_url, :ticket_price, :description, 
      :date_range_from, :date_range_to, :venue_address, :venue_address1, :city_id, :state_id, :state, :volunteer_ids => [])
    end
end