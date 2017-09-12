class EventsController < ApplicationController
  
  before_action :set_event, only: [:show, :edit, :update, :destroy]
  before_filter :validate_user_role
  helper_method :sort_direction
  @permitted_roles = [Role.EVENTS_FELLOW,
                      Role.CITY_PRESIDENT,
                      Role.NATIONAL_EVENTS_HEAD]
  class << self; attr_reader :permitted_roles end

  # GET /events
  # GET /events.json
  # -> Show all events
  # -> Show all events matching search query
  def index
  	flash[:error]=""
    flash[:alert]=""

    logged_in_user = User.find(session[:session_user])

    if params[:search]
    	if(logged_in_user.city_id == 25) #National 
    		@events = Event.where("event_name LIKE ?", "%#{params[:search]}%")
        @events = @events.paginate(:per_page => 5, :page => params[:page])
    	else
    		@events = Event.where(:city_id => logged_in_user.city_id).where("event_name LIKE ?", "%#{params[:search]}%")
        @events = @events.paginate(:per_page => 5, :page => params[:page])
    	end
      
      event_count = @events.length
      if event_count < 1
        flash[:alert] = "No event found"
      end
    else
    	if(logged_in_user.city_id == 25) #National
        if (params[:sort] && params[:direction])
    		  @events = Event.order(params[:sort] + ' ' + params[:direction])
          @events = @events.paginate(:per_page => 5, :page => params[:page])
        else
          @events = Event.all
          @events = @events.paginate(:per_page => 5, :page => params[:page])
        end
    	else
    		@events = Event.where(:city_id => logged_in_user.city_id)
        @events = @events.paginate(:per_page => 5, :page => params[:page])
    	end
    end
  end

  # GET /events/1
  # GET /events/1.json
  def show
    
  end

  # GET /events/new
  def new
    @event = Event.new
    @volunteers = []
    @cities = []
  end

  # GET /events/1/edit
  def edit
    @state= State.where(:id=> @event.state_id)
    @cities= City.where(:state_id=>@event.state_id)
    @volunteers = User.where(:city_id=>@event.city_id, :is_deleted => 0, :id=> UserRoleMap.select("user_id").where(:role_id=> Role.where(role: "Volunteer")))
    
   # @volunteers= User.where('users.city_id => @event.city_id'&&( 'users.is_deleted is null or users.is_deleted=0'), :id=> UserRoleMap.select("user_id").
   # where(:role_id=> Role.where(role: "Volunteer")))

    @selected_volunteers = User.select("id").where(:id=>EventVolunteerMap.select("volunteer_id").where(:event_id=> @event.id))
    
    @selected_ids = Array.new
    
    @selected_volunteers.each do |volunteer|
      @selected_ids.push volunteer.id
    end
  end

  # POST /events
  # POST /events.json
  # -> Create new event
  # -> Formes event volunteer map
  def create
    @event = Event.new(event_params)
    
    respond_to do |format|
      
      if @event.volunteer_ids == nil
        return
      end
      if @event.save
        @event.volunteer_ids.to_a.each do |volunteer_id|
          if volunteer_id.present?
            @event_volunteer_map = EventVolunteerMap.new
            @event_volunteer_map.assign_attributes({:event_id => @event.id, :volunteer_id=> volunteer_id})
            @event_volunteer_map.save(:validate=>false)
          end
        end
        format.html { redirect_to @event, notice: 'Event was successfully created.' }
        format.json { render action: 'show', status: :created, location: @event }
      else
        @volunteers = Array.new
        @cities = City.where(:state_id => event_params[:state_id]).order(:name)
        @selecte_city = event_params[:city_id]
        format.html { render action: 'new' }
        format.json { render json: @event.errors, status: :unprocessable_entity }
      end
       
    end
  end

  # PATCH/PUT /events/1
  # PATCH/PUT /events/1.json
  def update

    respond_to do |format|
      if @event.update(event_params)
          
          @volunteer_ids=event_params[:volunteer_ids] 
          
          @existing_vol_ids = ''
          @new_vol_ids = ''
          
          EventVolunteerMap.where(:event_id => @event.id).destroy_all
          @volunteer_ids.to_a.each do |volunteer_id|
            if volunteer_id.present?
              # @existing_event_volunteer_maps= EventVolunteerMap.where(:event_id => @event.id)
              # puts @existing_event_volunteer_maps
              # if @existing_event_volunteer_maps.present?
                # @existing_event_volunteer_maps.to_a.each do |existing_id|
                    @event_volunteer_map = EventVolunteerMap.new
                    @event_volunteer_map.assign_attributes({:event_id => @event.id, :volunteer_id=> volunteer_id})
                    @event_volunteer_map.save(:validate=>false)
                  end
            end
            
              format.html { redirect_to @event, notice: 'Event was successfully updated.' }
              format.json { head :no_content }
            else
              @volunteers = Array.new
              #@cities = []
              @cities = City.where(:state_id => event_params[:state_id]).order(:name)
              @selecte_city = event_params[:city_id]
              format.html { render action: 'edit' }
              format.json { render json: @event.errors, status: :unprocessable_entity }
      end
      end
  end

  # DELETE /events/1
  # DELETE /events/1.json
  def destroy
    @eventdonation = EventDonation.find_by_event_id(@event.id)
    
    if @eventdonation.present?
      flash[:error] = 'This Event is associated with some donations. It can not be deleted.'
    else
      @event.destroy
      flash[:alert] = 'Event is deleted successfully.'
    end
    
    respond_to do |format|
      format.html { redirect_to events_url }
      format.json { head :no_content }
    end
  end
  
  # -> To dynamically populate select form tag using JS
  # -> Renders a partial populated with cities from state
  #    in parameters
  def dynamic_cities
    @cities = City.where(:state_id => params[:state_id]).order(:name)
    render :partial => "cities", :object => @cities
  end
  
  # -> To dynamically populate select form tag using JS
  # -> Renders a partial populated with citywise volunteers
  def dynamic_volunteers_citywise
    @volunteers = User.where(:city_id=>params[:city_id] , :is_deleted => 0,:id=> UserRoleMap.select("user_id").
    where(:role_id=> Role.where(role: "Volunteer"))).order("concat(users.first_name,users.last_name)")
    render :partial => "volunteer", :object => @volunteers
  end

  # -> To dynamically populate select form tag using JS
  # -> Renders a partial populated with statewise volunteers
  def dynamic_volunteers_statewise
    @volunteers = User.where(:id=> UserRoleMap.select("user_id").where(:role_id=> Role.where(role: "Volunteer")),
                             :is_deleted => 0, :city_id=> City.select("id").where(:state_id=>params[:state_id])).order("concat(users.first_name,users.last_name)")
    render :partial => "volunteer", :object => @volunteers
  end

  private

  def sort_direction
    params[:direction] || "asc"
  end

  def sort_
    
  end

  def validate_user_role
    validate_user *EventsController.permitted_roles, session[:roles], MadConstants.home_page
  end
  # Use callbacks to share common setup or constraints between actions.
  def set_event
    @event = Event.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def event_params
    params.require(:event).permit(:event_name, :image_url, :ticket_price, :description,
                                  :date_range_from, :date_range_to, :venue_address, :venue_address1, :status, :city_id, :state_id, :volunteer_ids => [])
  end
end
