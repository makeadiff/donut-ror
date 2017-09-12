Makeadiff::Application.routes.draw do
  
  # Root at first as it is the most accessed page.
  root to: 'homes#index'
  
  get 'free_pool/show'
  get '/dynamic_free_pool_users' => 'free_pool#dynamic_free_pool_users'
  post '/dynamic_free_pool_users' => 'free_pool#assign'

  get 'events_donation_approvals/show'
  put 'events_donation_approvals/show' => 'events_donation_approvals#update'
  get 'events_donation_approvals/edit_donation/:donation_id' => 'events_donation_approvals#edit_donation'
  post 'events_donation_approvals/edit_donation/:donation_id' => 'events_donation_approvals#edit_donation'


  resources :eventtransactions
  get "eighty_g_approval/show"
  get "eighty_g_approval/emails_sent"
  put 'eighty_g_approval/show' => 'eighty_g_approval#update'

  #resources :add_volunteers
  
  #post 'reports_tos' => 'add_volunteers#create'
  #get 'reports_to' => 'add_volunteers'

  get '/dynamic_pocs' => 'volunteers#dynamic_pocs'
  get '/dynamic_managers' => 'users#dynamic_managers'
  get '/dynamic_managers_by_city' => 'users#dynamic_managers_by_city'
  get '/is_validate_role' => 'users#validate_role'

  get '/citywise_volunteers' => 'events#dynamic_volunteers_citywise'
  get '/statewise_volunteers' => 'events#dynamic_volunteers_statewise'
  get '/statewise_cities' => 'events#dynamic_cities'
  
  get 'mobile_cfr_prods/cfrproducts'
  
  get 'mobile_events/events'
  get 'mobile_approvals/donations_to_be_approved_by_poc'
  post 'mobile_approvals/poc_approve_donation'
  get 'mobile_approvals/donations_grouped_by_poc'
  post 'mobile_approvals/fc_approve_handover'
  
  resources :cfrtransactions
  resources :events
  resources :homes
  resources :cfr_products
  resources :mobile_cfr_prods
  resources :cities
  resources :states
  resources :roles
  resources :volunteers

  devise_for :users, :skip => [:registrations]

  #resources :products
  resources :users
  resources :mobileuser
  resources :donation_approval
  resources :mobileauth
  
  post 'mobile_reports/vol_report'
  
  
  get 'donation_approval/show'
  put 'donation_approval/show' => 'donation_approval#update'
  get 'donation_approval/edit_donation/:donation_id' => 'donation_approval#edit_donation'
  post 'donation_approval/edit_donation/:donation_id' => 'donation_approval#edit_donation'
  get 'donation_approval/delete/:donation_id' => 'donation_approval#delete'
  
  get '/nationalcfrreports/show' => 'nationalcfrreports#show'
  get '/nationaltallyreports/show' => 'nationaltallyreports#show'
  get '/nationaltallyeventreports/show' => 'nationaltallyeventreports#show'
  get '/nationaleventreports/show' => 'nationaleventreports#show'
  get '/nationalfinancereports/show' => 'nationalfinancereports#show'
  get '/eventsfellowreports/show' => 'eventsfellowreports#show'
  get '/volreports/show' => 'volreports#show'
  get '/citypresidentreports/show' => 'citypresidentreports#show'
  get '/cfrfellowreports/show' => 'cfrfellowreports#show'
  get '/financefellowreports/show' => 'financefellowreports#show'
  get '/pocreports/show' => 'pocreports#show'
  get '/nationalcfrreports/report' => 'nationalcfrreports#report'
  get '/nationaltallyreports/report' => 'nationaltallyreports#report'
  get '/nationaltallyeventreports/report' => 'nationaltallyeventreports#report'
  get '/nationaleventreports/report' => 'nationaleventreports#report'
  get '/nationalfinancereports/report' => 'nationalfinancereports#report'
  get '/eventsfellowreports/report' => 'eventsfellowreports#report'
  get '/volreports/report' => 'volreports#report'
  get '/citypresidentreports/report' => 'citypresidentreports#report'
  get '/cfrfellowreports/report' => 'cfrfellowreports#report'
  get '/financefellowreports/report' => 'financefellowreports#report'
  get '/pocreports/report' => 'pocreports#report'
  
  resources :donations
  resources :event_donations

  get '/donations/send_acknowledgement/:donation_id' => 'donations#send_acknowledgement'

  # get 'offline_donation' => 'offline_donation#create'
  get 'offline_donation/mad' => 'offline_donation#mad'
  
  get 'offline_donation/tmad' => 'offline_donation#tmad'
  get 'offline_donation/getprods' => 'offline_donation#getprods'
  get 'offline_donation/eventmad' => 'offline_donation#eventmad'
  get 'offline_donation/getevents' => 'offline_donation#getevents'

  get 'donation_approval/send_receipt/:donation_id' => 'donation_approval#send_receipt'
  
  #If no route matches
  get ":url" => 'application#redirect_user_404', :constraints => { :url => /.*/ }
  
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  
end
