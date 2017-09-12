class DonationMailer < ActionMailer::Base
  default :from => "brahma.swlw@gmail.com"
  
  def confirm_mail(value_text)
    puts 'mail sending....' + value_text
    mail(:to => "sg.brahma@gmail.com", :subject => "Welcome to MAD..............")
    puts 'mail sent....'
  end
end
