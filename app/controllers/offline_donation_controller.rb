class OfflineDonationController < ActionController::Base
  include SmsHelper
  include EmailHelper
  include EmailTemplateHelper
  
  skip_before_filter :verify_authenticity_token
  
  def show
    respond_to do |format|
      format.xml { render :xml => @donation.to_xml(:only => [:id]) }
    end
  end
  
  def mad
    @don_string = donation_params[:content]
    
    @don_string= @don_string.split(" ")

    rendered = nil

    if @don_string[0] == 'TMAD'
      tmad
    elsif @don_string[0] == 'EVENTMAD'
      rendered = eventmad
    elsif @don_string[0] == 'GETPRODS'
      getprods
    elsif @don_string[0] == 'GETEVENTS'
      getevents
    end
    render :text => 'Done.' unless rendered

  end

  # TMAD <name>**<phone_number>**<Email_id>**<Amount>**<80G>**<product_id>
  
  def tmad
    @donation = Donation.new
    @donation_string = donation_params[:content]

    if don_string_is_validated?(@donation_string)
      @donation_string= @donation_string.slice(4,@donation_string.length).gsub(/"|^ +| $+|\n/i,'').to_s
      @donation_string= @donation_string.split('**')
      name = @donation_string[0]
      phone_no = @donation_string[1]
      email_id = @donation_string[2]
      amount = @donation_string[3]
      eighty_g = @donation_string[4]
      prod_id = @donation_string[5] if @donation_string.size == 6

      @donour = Donour.find_unique(@donation_string[1], @donation_string[2])   

      if @donour.nil?
        # Creates new donour entry for the information found
        @donour = Donour.new
        @donour.assign_attributes({:first_name => name,
                                   :phone_no => phone_no,
                                   :email_id => email_id
                                  })
        unless @donour.save
          respond_to do |format|
            format.html { render action: 'new' }
            format.xml { render xml: @donour.errors, status: :unprocessable_entity }
          end
        end
      end
          
        # already existed donour found
      @donation.assign_attributes({:donation_type => 'GEN', :version => 1, 
                                   :fundraiser_id => 1, :donour_id => @donour.id, 
                                   :donation_amount => amount,
                                   :donation_status => Donation.STATUS_TO_BE_APPROVED_BY_POC,
                                   :updated_by => 1})
           
      @donation.assign_attributes(:product_id => CfrProduct.new.gen_prod_id)
           
      if @donation_string.length == 6
        @product = CfrProduct.find_by_id([prod_id.to_i])    
        if @product.present?
          @donation.assign_attributes({:donation_type => 'OTH', :product_id => @product[:id]})
        end
      end     
           
      @fundraiser = User.find_by_phone_no(get_10_digit_phone_no(donation_params[:msisdn]))
           
      if @fundraiser.present?
        @donation.assign_attributes({:fundraiser_id => @fundraiser[:id],
                                     :updated_by => @fundraiser[:id]})
      else
        respond_to do |format|
          format.html #{ render action: 'new' }
          format.xml { render xml: @donour.errors, status: :unprocessable_entity }
        end
      end
           
           
      if (eighty_g.to_s == 'Y' || eighty_g.to_s == 'y')
        @donation.assign_attributes(:eighty_g_required => true)
      else
        @donation.assign_attributes(:eighty_g_required => false)
      end  
           
      if amount.to_f > 0
        @donation.assign_attributes(:donation_amount => amount.to_f)
      else
        respond_to do |format|
          format.html { render action: 'new' }
          format.xml { render xml: @donour.errors, status: :unprocessable_entity }
        end
      end

      @donation.assign_attributes({:source_id => get_sms_source_id})

      if @donation.save  
        puts 'donations..saved....'   
        #  send acknowledement sms and email to donor and fundraiser    
        send_ack_sms(@donour.first_name, @donation.donation_amount.to_s, @donour.phone_no.to_s)
        send_sms_to_fundaraiser(@donour.first_name, @donation.donation_amount.to_s, @fundraiser.phone_no.to_s)    
        if @donour.email_id.present?
          ack_mail_body = ''
          if @donation.eighty_g_required.to_s == 'true'
            ack_mail_body = ack_mail_template_with_eighty_g(@donour.first_name, @donour.email_id, @donation.donation_amount.to_s, @donation.id.to_s, 'General Donation')  
          else
            ack_mail_body = ack_mail_template(@donour.first_name, @donour.email_id, @donation.donation_amount.to_s, @donation.id.to_s, 'General Donation')
          end    
          send_mails(@donour.email_id, 'Donation Acknowledgement', ack_mail_body) 
        end
      end

    else
      wrong_tmad_format(donation_params[:msisdn], @missing_param)
      #raise TypeError, "Something seems to be wrong: #{@missing_param}"
    end
  end
  
  #EVENTMAD <name>**<phone_number>**<Email_id>**<event_id>**<amount>[**<sponsership_amount>]
  
  def eventmad
    #EVENTMAD <name>**<phone_number>**<Email_id>**<event_id>**<amount>
    @donation = EventDonation.new
    @donation_string = donation_params[:content]
    if event_don_string_is_validated?(@donation_string)
      @donation_string= @donation_string.slice(8,@donation_string.length).gsub(/"|^ +| $+|\n/i,'').to_s
      @donation_string= @donation_string.split('**') 
      
      name = @donation_string[0]
      phone_no = @donation_string[1]
      email_id = @donation_string[2]
      event_id = @donation_string[3]
      amount = @donation_string[4]
      sponser_amount = @donation_string[5] if @donation_string.size == 6

      @donour = Donour.find_unique(@donation_string[1], @donation_string[2])
   
      if @donour.nil?
        # Creates new donour entry for the information found
        @donour = Donour.new
        @donour.assign_attributes({:first_name => name,
                                   :phone_no => phone_no,
                                   :email_id => email_id
                                   })

        unless @donour.save
          respond_to do |format|
            format.html { render action: 'new' }
            format.xml { render xml: @donour.errors, status: :unprocessable_entity }
          end
        end
      end
       
      @donation.assign_attributes({:version => 1, 
                                  :donour_id => @donour.id, 
                                  :donation_status => Donation.STATUS_TO_BE_APPROVED_BY_EVENT_HEAD,
                                  })
         
      @donation.assign_attributes({:fundraiser_id => 1, 
                                  :donation_amount => amount.to_i,
                                  :updated_by => 1})
      begin
        @event = Event.find(event_id.to_i)
      rescue ActiveRecord::RecordNotFound
        # send sms that event was not found
      end

      if @event.present?
        @donation.assign_attributes({:event_id => @event[:id], 
                              :donation_type => 'EVNT', 
                              :donation_amount => @event[:ticket_price]})

        if !sponser_amount.nil?
          @donation.assign_attributes({
                              :donation_type => 'EVNT_SPON',
                              :donation_amount => sponser_amount.to_i
                              })
                
        else
          @ticket = EventTicketType.find_by ticket_price: amount.to_i, event_id: @event[:id]

          if @ticket.present?
            @donation.assign_attributes({
                        :event_ticket_type_id => @ticket[:id],
                        :donation_amount => @ticket[:ticket_price]})
          else
            render :text => "Invalid Amount. This event dosen't have a ticket of that amount"
            return 1
          end
        end
      end   
         
      @fundraiser = User.find_by_phone_no(get_10_digit_phone_no(donation_params[:msisdn]))
         
      if @fundraiser.present?
        @donation.assign_attributes({:fundraiser_id => @fundraiser[:id], :updated_by => @fundraiser[:id]})
      else
        # render :text => "Your number is not registered as a fundraiser. You cannot make donations"
        puts "Your number is not registered as a fundraiser. You cannot make donations"
        return
      end

      @donation.assign_attributes({:source_id => get_sms_source_id})
        
      if @donation.save
        # send_confirmation_notification(@donation)
        # send acknowledement sms and email
        send_ack_sms(@donour.first_name, @donation.donation_amount.to_s, @donour.phone_no.to_s)
        if @donour.email_id.present?
          ack_mail_body = ack_mail_template(@donour.first_name, @donour.email_id, @donation.donation_amount.to_s, @donation.id.to_s, 'General Donation')
          send_mails(@donour.email_id, 'Donation Acknowledgement', ack_mail_body) 
        end
      end
    else
      puts "WRONG!! WRONG!! #{@missing_param}"
      wrong_eventmad_format(donation_params[:msisdn], @missing_param)
    end
  end
  
  #GETEVENTS 
  def getevents
  	puts "Info on Events..."
    # Get all events of the volunteer
    user = User.select("id").where(:phone_no => get_10_digit_phone_no(params[:msisdn]))
    @events = Event.where(:id => EventVolunteerMap.select("event_id").where(:volunteer_id => user))

    begin
      if @events.present?
        all_events = 'The events associated to you are:'
        cnt = 0
        @events.each do |event| 
          event.ticket_type.each do |ticket|
	        	if cnt < 5
          	all_events += "\n" + 'ID:' + event.id.to_s + ' EVENT:' + event.event_name.to_s
            all_events += ' TICKET: ' + ticket.id.to_s + ') ' + ticket.name + ' AMOUNT:' + ticket.ticket_price.to_s
				    cnt = cnt + 1
			    end
     	  end

  			if cnt == 5
  				puts all_events
  				send_sms(params[:msisdn], all_events)
  				all_events = 'The events associated to you are:'
  				cnt = 0
  			end
      end
         
      if cnt > 0
        while cnt < 5 do
          all_events += "\n" + 'ID: EVENT: TICKET: AMOUNT:'
          cnt = cnt + 1
        end
      end

      #puts all_events.inspect
      if cnt == 5
       	puts all_events
       	send_sms(params[:msisdn], all_events)
      end
    end

    rescue Exception => e
      logger.warn "Unable to send events: #{e}" 
    end

    render :action=>'getevents'
  end


  def getprods
    # Get all products of the volunteer
     @cfr_products = CfrProduct.where(:city_id => User.select("city_id").where(:phone_no => get_10_digit_phone_no(params[:msisdn])))
     begin
       if @cfr_products.present?
         all_prods = 'The products associated to you are:'
         cnt = 0
         @cfr_products.each do |cfr_prod| 
           if cnt < 5
            all_prods += "\n" + 'ID:' + cfr_prod.id.to_s + ' PRODUCT:' + cfr_prod.name
           elsif cnt == 5
             all_prods = 'The products associated to you are:'
             all_prods += "\n" + 'ID:' + cfr_prod.id.to_s + ' PRODUCT:' + cfr_prod.name
           end
           cnt = cnt + 1
           if cnt == 5
             send_sms(params[:msisdn], all_prods)
             all_prods = 'The products associated to you are:'
             cnt = 0
           end
         end
         
         if cnt > 0
           while cnt < 5 do
             all_prods += "\n" + 'ID: PRODUCT:'
             cnt = cnt + 1
           end
         end
         
         if cnt == 5
           send_sms(params[:msisdn], all_prods)
         end
       end
     rescue Exception => e
       logger.warn "Unable to send products: #{e}" 
     end

  end
  
  def send_confirmation_notification(donation)
    donour = Donour.find(donation.donour_id)
    
    if donour.present?
      product_or_event_name = ''
      event = Event.find(donation.event_id) 
      if event.present?
        product_or_event_name = event.event_name
      else
        product_or_event_name = 'General Donation'
      end
      donour_name = donour.first_name
      if donour.last_name.present?
        donour_name += ' ' + donour.last_name
      end
      
      begin  
        event_confirmation_sms(donour_name, donation.donation_amount.to_s, donour.phone_no.to_s,product_or_event_name)
      rescue
        #puts " alert msg sms not sent***************************"
      end                
      if donour.email_id.present?
        begin          
          email_text = confirmation_mail_template_for_event(donour_name, donour.email_id, donation.donation_amount.to_s, donation.id.to_s, product_or_event_name)
          send_mails( donour.email_id , 'Donation Confirmation', email_text)
        rescue
          # alert msg email not sent
        end
      end 
    end
  end

  private

  def type_is_validated?(donation_string)
    donation_type = donation_string.split(" ")[0]
    @missing_param = "Type"
    %w[TMAD EVENTMAD GETPRODS GETEVENTS].include?(donation_type)
  end

  def name_is_validated?(donation_string_arr)
    donation_name = donation_string_arr[0]
    @missing_param = "Name"
    !(donation_name.empty? || donation_name.nil? || !donation_name.match(/\A[A-Za-z]*[\s]*[A-Za-z]+\Z/))
  end

  def num_is_validated?(donation_string_arr)
    donation_num = donation_string_arr[1]
    @missing_param = "Phone Number"
    !(donation_num.nil? || donation_num.empty? || donation_num.length < 10 || donation_num.length > 12 || !donation_num.match(/^\d+$/))
  end

  def email_is_validated?(donation_string_arr)
    email_regex = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z]+)*\.[a-z]+\z/i
    donation_email = donation_string_arr[2]
    @missing_param = "Email ID"
    !(donation_email.nil? || donation_email.empty? || donation_email !~ email_regex)
  end

  def amount_is_validated?(donation_string_arr)
    char_regex = /[A-Z]|[a-z]/
    donation_amount = donation_string_arr[3]
    @missing_param = "Amount"
    !(donation_amount.nil? || donation_amount.empty? || donation_amount =~ char_regex)
  end

  def _80g_is_validated?(donation_string_arr)
    donation_80g = donation_string_arr[4]
    @missing_param = "80g status"
    !(donation_80g.nil? || donation_80g.empty? || !%w[y n Y N].include?(donation_80g))
  end

  def productid_is_validated?(donation_string_arr)
    @missing_param = "Product ID"
    !(donation_string_arr.length == 6 && donation_string_arr[5] =~ /[A-Z]|[a-z]/)
  end

  def event_id_is_validated?(event_don_string_arr)
    donation_eventid = event_don_string_arr[3]
    @missing_param = "Event ID"
    !(donation_eventid.nil? || donation_eventid.empty? || donation_eventid =~ /[A-Z]|[a-z]/)
  end

  def event_amount_is_validated?(event_don_string_arr)
    char_regex = /[A-Z]|[a-z]/
    donation_amount = event_don_string_arr[4]
    if %w[spon SPON sponser SPONSER].include?(donation_amount)
      @missing_param = "Sponsership Amount"
      return (event_don_string_arr.length == 6 && event_don_string_arr[5] !~ char_regex)
    end
    @missing_param = "Amount"
    !(donation_amount.nil? || donation_amount.empty? || donation_amount =~ char_regex)
  end

  def don_string_is_validated?(donation_string)
    donation_string = donation_string.strip

    type_res = type_is_validated?(donation_string)
    
    donation_string = donation_string.split(" ", 2)[1].gsub(/"|^ +| $+|\n/i,'').to_s
    donation_string_arr = donation_string.split("**")
    type_res && name_is_validated?(donation_string_arr) && num_is_validated?(donation_string_arr) && email_is_validated?(donation_string_arr) && amount_is_validated?(donation_string_arr) && _80g_is_validated?(donation_string_arr) && productid_is_validated?(donation_string_arr)
  end

  def event_don_string_is_validated?(donation_string)
    donation_string = donation_string.strip

    type_res = type_is_validated?(donation_string)
    
    donation_string = donation_string.split(" ", 2)[1].gsub(/"|^ +| $+|\n/i,'').to_s
    donation_string_arr = donation_string.split("**")
    type_res && name_is_validated?(donation_string_arr) && num_is_validated?(donation_string_arr) && email_is_validated?(donation_string_arr) && event_id_is_validated?(donation_string_arr) && event_amount_is_validated?(donation_string_arr)
  end

  def get_sms_source_id
    Source.where(source: "SMS").id
  end

  def get_10_digit_phone_no(phone_no)
    if phone_no.length > 10
      phone_no = phone_no.slice(2, phone_no.length) 
    else
      phone_no 
    end
  end

  # Use callbacks to share common setup or constraints between actions.l
  def set_donation
    #@donation = Donation.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def donation_params
    params.permit(:phonecode, :keyword,:location,:carrier, :content,:msisdn,:timestamp)
  end
  
end
