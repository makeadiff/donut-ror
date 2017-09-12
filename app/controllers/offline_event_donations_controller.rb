class OfflineEventDonationsController < ActionController::Base
  # NOTE: I don't think this file is used. All the necessary code is in offline_donation_controller
  @basicauth = BasicAuth.find(:first)
  
  http_basic_authenticate_with :name => @basicauth.name, :password => @basicauth.password
  skip_before_filter :verify_authenticity_token
  
  def show
    respond_to do |format|
      format.xml { render :xml => @donation.to_xml(:only => [:id]) }
    end
  end
  
  def eventmad
    #EVENTMAD <name>**<phone_number>**<Email_id>**<event_id>
    @donour = Donour.find_by_phone_no(donation_params[:msisdn])
    
    # check donation made for what ? Event or Product or Dream Tee donations
    @donation = Donation.new
    @donation_string = donation_params[:content]
    @donation_string= @donation_string.slice(8,@donation_string.length).gsub(/"|^ +| $+|\n/i,'').to_s
    @donation_string= @donation_string.split('**')    
    is_wrong_format = false
    missing_param= ""
    if ((@donation_string.nil? ) || @donation_string.size<4 || (@donation_string[0].nil? ) || (@donation_string[1].nil? ) || (@donation_string[2].nil? ) || (@donation_string[3].nil? ))
        
          # send rejection sms due to incorrect format 
          is_wrong_format=true
          missing_param= "something"
          puts "the size is errorenous"
          #wrong_tmad_format(donation_params[:msisdn])
          
    else
      name= @donation_string[0]
      phone_no= @donation_string[1]
      email_id= @donation_string[2]
      event_id= @donation_string[3]
      if ((name.length<0)&& name.match(/\A[A-Za-z]*[\s]*[A-Za-z]+\Z/))
            
            is_wrong_format= false
          else 
            is_wrong_format=true
            missing_param= 'Name'
          end
      if ((phone_no.length>=10)&& (phone_no.length<=12))
          is_wrong_format= false
      else
            is_wrong_format=true 
            if missing_param.length>0
             else
               
            missing_param= 'Phone Number'
            end
      end
      if ((@donation_string[2].include? "@") && (@donation_string[2].include? "."))
            is_wrong_format= false
      else
            is_wrong_format=true
             if missing_param.length>0
             else
            missing_param= 'Email Id'
            end
      end
      
       if (is_wrong_format==false)
        respond_to do |format|
        if @donour.nil?
        # Creates new donour entry for the information found
        @donour = Donour.new
        @donour.assign_attributes({:first_name =>@donation_string[0],
                                   :phone_no => @donation_string[1],
                                   :email_id => @donation_string[2]
                                   })
        # Validations for all required fields
        #EVENTMAD <name>**<phone_number>**<Email_id>**<event_id>
        
          if (:first_name.length<0)
          elsif ((:phone_no.length>=10)&& (:phone_no.length<=12))
          elsif ((@donation_string[2].include? "@") && (@donation_string[2].include? "."))
          else
              puts @donour.errors
              format.html { render action: 'new' }
              format.xml { render xml: @donour.errors, status: :unprocessable_entity }
          end
          
          
        
        Rails.logger.warn @donour.inspect
        if @donour.save
           
        else
          format.html { render action: 'new' }
          format.xml { render xml: @donour.errors, status: :unprocessable_entity }
        end
        
      else
        # already existed donour found
      end
      
      if !@donour.nil?
        
           @donation.assign_attributes({ :version => 1, 
                                    :donour_id => @donour.id, 
                                    :donation_status => Donation.STATUS_TO_BE_APPROVED_BY_POC,
                                    })
           
           @donation.assign_attributes({:donation_type => 'GEN', :version => 1, 
                                    :fundraiser_id => 1, :donour_id => @donour.id, 
                                    :donation_status => Donation.STATUS_TO_BE_APPROVED_BY_POC,
                                    :product_id => 0,
                                    :donation_amount => @donation_string[3],
                                    :updated_by => 1})
           
           
           if @donation_string.length == 6
              @event = Event.find[@donation_string[3].to_i]
              
              if @event.present?
                @donation.assign_attributes({:donation_type => 'EVNT', :donation_amount => @event.ticket_price})
              end
           else 
             @donation.assign_attributes({:donation_type => 'GEN'})
           end     
           
           @fundraiser = User.find_by_phone_no(donation_params[:msisdn])
           
           if @fundraiser.present?
             @donation.assign_attributes({:fundraiser_id => @fundraiser[:id],
                                        :updated_by => @fundraiser[:id]})
           else
              format.html { render action: 'new' }
              format.xml { render xml: @donour.errors, status: :unprocessable_entity }
           end
           
        @donation.assign_attributes(:source_id => get_sms_source_id)
          
        if @donation.save
          format.html { redirect_to @donation, notice: 'Donation added successfully.' }
          #format.json { render action: 'show', status: :found, location: @donation }
          format.xml { render action: 'show', status: :created, location: @donation }    
        else 
          format.html { render action: 'new' }
          format.xml { render xml: @donation.errors, status: :unprocessable_entity }
        end
        end
      end
      end
    end
    if (is_wrong_format==true)
          wrong_eventmad_format(donation_params[:msisdn], missing_param)
    end
  end
  
  
    #GETEVENTS 
  def getevents
    # Get all products of the volunteer
     @events = Event.where(:city_id => User.select("city_id").where(:phone_no => params[:msisdn]))
     puts @events
     if @events.present?
       @all_events = ''
       @events.each do |event| 
          @all_events += event.id.to_s + ',' + event.event_name + "\n"
       end
       puts @all_events
     end
     respond_to do |format|
       format.xml { render xml: @all_events, status: 200 }
     end
   end
  
  private
    # Use callbacks to share common setup or constraints between actions.l
    def set_donation
      #@donation = Donation.find(params[:id])
    end

    def get_sms_source_id
      Source.where(source: "SMS").id
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def donation_params
      params.permit(:phonecode, :keyword,:location,:carrier, :content,:msisdn,:timestamp)
    end
end
