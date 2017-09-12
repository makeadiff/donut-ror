class MadConstants
  
  class << self; attr_accessor :results_per_page end
  class << self; attr_reader :new_users_page end
  class << self; attr_reader :home_page end
  class << self; attr_reader :permission_denied end
  class << self; attr_reader :donation_approval_path end
  class << self; attr_reader :events_donation_approval_path end
  class << self; attr_reader :error_message end
  class << self; attr_reader :error_message end
  class << self; attr_reader :error_message_no_city_or_national_level_managers end
  class << self; attr_reader :vol_reports_path end
  class << self; attr_reader :error_message_no_manager_selected end
  class << self; attr_reader :free_pool_path end
  
  class << self; attr_reader :eighty_g_approval_path end
  class << self; attr_reader :national_cfr_reports_path end
  class << self; attr_reader :national_event_reports_path end
  class << self; attr_reader :national_finance_reports_path end
  class << self; attr_reader :city_president_reports_path end
  class << self; attr_reader :cfr_fellow_reports_path end
  class << self; attr_reader :event_fellow_reports_path end
  class << self; attr_reader :finance_fellow_reports_path end
  class << self; attr_reader :poc_reports_path end
  
  # Constants for reports
  class << self; attr_reader :date end # Date
  class << self; attr_reader :fundraiser_name end# Fundraiser Name
  class << self; attr_reader :fundraiser_email end# Fundraiser email
  class << self; attr_reader :poc_name end# POC Name
  class << self; attr_reader :poc_email end# POC email
  class << self; attr_reader :donor_name end# Donor Name
  class << self; attr_reader :email_id end# Email ID
  class << self; attr_reader :phone_no end# Phone No
  class << self; attr_reader :amount_donated end# Amount Donated
  class << self; attr_reader :receipt_status end# Receipt Status
  class << self; attr_reader :event_code end# Event Code
  class << self; attr_reader :event_name end# Event Name
  class << self; attr_reader :ticket_amount end# Ticket Amount
  class << self; attr_reader :volunteer end# Volunteer
  class << self; attr_reader :donation_type end# Donation Type
  class << self; attr_reader :donation_status end# Donation Status
  class << self; attr_reader :eighty_g_required end# Eighty g Required
  class << self; attr_reader :product end# Product
  class << self; attr_reader :donation_amount end# Donation Amount
  class << self; attr_reader :city end# City
  class << self; attr_reader :app_http_root_path end# http://ec2-54-225-24-219.compute-1.amazonaws.com:3000

  
  @results_per_page = 5
  @new_users_page = '/users/new'
  @home_page = '/homes'
  @permission_denied = 'You do not have permission to access that Page.'
  @donation_approval_path = '/donation_approval/show'
  @events_donation_approval_path = '/events_donation_approvals/show'
  @error_message = 'Some Error occurred. We are sending a team of highly trained Gorillas to fix this :-)'
  @error_message_no_city_or_national_level_managers = 'No National or City Level Managers available for this City. Please assign them first'
  @vol_reports_path = '/volreports/show'
  @national_cfr_reports_path = '/nationalcfrreports/show'
  @national_tally_reports_path = '/nationaltallyreports/show'
  @national_event_reports_path = '/nationaleventreports/show'
  @national_finance_reports_path = '/nationalfinancereports/show'
  @city_president_reports_path = '/citypresidentreports/show'
  @cfr_fellow_reports_path = '/cfrfellowreports/show'
  @event_fellow_reports_path = '/eventsfellowreports/show'
  @finance_fellow_reports_path = '/financefellowreports/show'
  @poc_reports_path = '/pocreports/show'
  @error_message_no_manager_selected = 'No Manager Selected'
  @free_pool_path = '/free_pool/show'
  @eighty_g_approval_path = '/eighty_g_approval/show'
  
  # Constants for reports
  @date = 'Date'
  @fundraiser_name = 'Fundraiser'
  @fundraiser_email = 'Fundraiser Email ID'
  @poc_name = 'POC Name'
  @poc_email = 'POC Email'
  @donor_name = 'Donor'
  @email_id = 'Email ID'
  @phone_no = 'Phone No'
  @amount_donated = 'Amount Donated'
  @receipt_status = 'Receipt Status'
  @event_code = 'Event Code'
  @event_name = 'Event Name'
  @ticket_amount = 'Ticket Amount'
  @volunteer = 'Volunteer'
  @donation_type = 'Donation Type'
  @donation_status = 'Donation Status'
  @eighty_g_required = '80g Required'
  @product = 'Product'
  @donation_amount = 'Donation Amount'
  @city = 'City'
  @app_http_root_path = 'http://cfrapp.makeadiff.in:3000'
end