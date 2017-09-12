module EmailHelper
  
  def send_mails(don_to_address, don_subject, don_body)
    begin
    Pony.mail({
    :to => don_to_address.to_s,
    :subject => don_subject.to_s,
    :content_type => 'text/html', :html_body => don_body.to_s, 
    :via => :smtp, 
    
    :via_options => { 
      :address => 'smtp.gmail.com', 
      :port => 587, 
      :enable_starttls_auto => true,
      :user_name => 'noreply@makeadiff.in', 
      :password => 'noreplygonemad',
      :authentication => :plain,
      :domain => '54.225.24.219'
      } 
      })
    rescue Exception => e
      logger.warn "Unable to send mail: #{e}" 
    end 
  end
  
  def send_mails_with_attachment(don_to_address, don_subject, don_body, file, file_name)
    
    begin
    Pony.mail({
    :to => don_to_address.to_s,
    :subject => don_subject.to_s,
    :content_type => 'text/html', 
    :html_body => don_body.to_s, 
    :attachments => {file_name.to_s => file}, 
    :via => :smtp, 
    
    :via_options => { 
      :address => 'smtp.gmail.com', 
      :port => 587, 
      :enable_starttls_auto => true,
      :user_name => 'noreply@makeadiff.in', 
      :password => 'noreplygonemad',
      :authentication => :plain,
      :domain => '54.225.24.219'} 
      })
    rescue Exception => e
      logger.warn "Unable to send mail: #{e}" 
    end
  end
end