module SmsHelper
  
  def send_sms(don_phone_no, message)
    if don_phone_no.length == 10
      don_phone_no = '91' + don_phone_no
    end 
    
    data = ""
    data += "method=sendMessage"
    data += "&userid=2000030788"
    data += "&password=6BeNqpFy6"
    data += "&msg=" + message
    
    data += "&mask=MAD"        
    data += "&send_to=" + don_phone_no
    data += "&v=1.1"
    data += "&msg_type=TEXT"
    data += "&auth_scheme=PLAIN";
    
    require "net/http"
    require "uri"
    puts data
    @url_string = 'http://enterprise.smsgupshup.com/GatewayAPI/rest?' + data
    @url_string =  URI.encode(@url_string)
    
    # Need to take care of + sign explicitly as URI.encode doesnot encode that symbol
    url = URI.parse(@url_string.gsub('+', '%2B'))
    
    response = Net::HTTP.get_response(url)
    
    puts response.body
  end
  #"Donation of Rs. <amount> from <donor_first_name> has been added to Donut. Thank you."
  def send_sms_to_fundaraiser(don_name_param,don_amt_param, fundraiser_phone_no)
    msg = "Donation of Rs. " + don_amt_param + " from " + don_name_param +" has been added to Donut. Thank you."
    self.send_sms(fundraiser_phone_no, msg)
  end
  
  def send_ack_sms(don_name_param, don_amt_param, don_phone_no)
    msg = "Dear " + don_name_param + ", Thanks a lot for your contribution of Rs. " + don_amt_param + " towards Make a Difference. This is only an acknowledgement. A confirmation and e-receipt would be sent once the amount reaches us."
    self.send_sms(don_phone_no, msg) 
  end

  def send_thank_you_sms(don_name_param,  don_phone_no)
    msg = "Dear " + don_name_param + ", Thanks a lot for your contribution towards Make a Difference. "
    self.send_sms(don_phone_no, msg) 
  end
  
  def send_confirmation_sms(don_name_param, don_amt_param, don_phone_no)
    msg = "Dear " + don_name_param + ", We have mailed you the e-receipt for your contribution of Rs. " + don_amt_param + " towards Make A Difference. Thanks for choosing MAD."
    self.send_sms(don_phone_no, msg)    
  end
  
  def event_confirmation_sms(don_name_param, don_amt_param, don_phone_no,event_name, choice = nil)
    msg = "Dear " + don_name_param + ", Thanks a lot for your contribution of Rs." + don_amt_param + " during " + event_name + " conducted by Make a Difference. We have also sent you a confirmation  mail. This SMS or a printout of the confirmation mail will serve as the ticket."
    if choice
      if choice == -1
        msg = "Dear " + don_name_param + ", Thanks a lot for your contribution of Rs." + don_amt_param + " during sponsership conducted by Make a Difference. We have also sent you a confirmation  mail. This SMS or a printout of the confirmation mail will serve as the ticket."
      elsif choice == -2
        msg = "Dear " + don_name_param + ", Thanks a lot for your contribution of Rs." + don_amt_param + " during one time donation conducted by Make a Difference. We have also sent you a confirmation  mail. This SMS or a printout of the confirmation mail will serve as the ticket."
      elsif choice == -3 
        msg = "THANKYOU PLACEHOLDER MESSAGE"
      end
    end 
    self.send_sms(don_phone_no, msg)
  end

  def sponsership_confirmation_sms(don_name_param, don_amt_param, don_phone_no , event_name)
    msg = "Dear " + don_name_param + ". This is a Sponsership Placeholder message"
    self.send_sms(don_phone_no, msg)
  end

  def otd_confirmation_sms(don_phone_no)
    msg = "One Time Donation Placeholder Message"
    self.send_sms(don_phone_no, msg)
  end

  def thankyou_confirmation_sms(don_phone_no)
    msg = "Thank you Placeholder Message"
    self.send_sms(don_phone_no, msg)
  end
  
  def wrong_tmad_format(don_phone_no, don_missing_param)
    msg = "It seems you forgot to enter "+don_missing_param+" please try again the expected format is TMAD name**phone_number**Email_id**Amount**80G"
    puts msg
    self.send_sms(don_phone_no, msg)
  end
  
  def wrong_eventmad_format(don_phone_no, don_missing_param)
    msg = "It seems you forgot to enter "+don_missing_param+" please try again the expected format is EVENTMAD name**phone_number**Email_id**event_id**amount[**<sponsership_amount>]"
    self.send_sms(don_phone_no, msg)
  end
end