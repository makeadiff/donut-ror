class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  before_filter :authenticate_user!
  before_filter skip_filter  _process_action_callbacks.map(&:filter)
  #protect_from_forgery with: :exception
  protect_from_forgery :secret => '6844e4234cdbfe4c4efd31ec3fc002e2'
  
  # Extensive use of pagination and sorting is made in this application, please refer to the 
  # links below for implementation and documentation.
  # For this type of implementation we used here **gem "will_paginate", "~> 3.0.4"** this gem.
  # And the implementation is refered from following addresses
  #  1. -->   http://railscasts.com/episodes/240-search-sort-paginate-with-ajax?view=asciicast
  #  2. -->   http://railscasts.com/episodes/228-sortable-table-columns 

  # -> This code added to display a default page when any kind of exception will occures
  #    in our application
  # -> rescue_from(Exception){
  #    redirect_to '/500'
  #    }
  
  # -> Redirects to /users/sign_in post a successful log out.
  def after_sign_out_path_for(resource_or_scope)
    home_path = "/users/sign_in"
  end
  
  # -> Post a successful sign in, populates the session hash 
  #    with appropriate values.
  # -> Sets the user's roles.
  # -> The string returned by this method is the route to be
  #    redirected to post a successful log in.
  def after_sign_in_path_for(resource_or_scope)
    @session_user = current_user
    session[:session_user] = current_user.id
    session[:session_user_name] = "#{current_user.first_name} #{current_user.last_name}"
    @user_role_map = UserRoleMap.all(:conditions=> ["user_role_maps.user_id = :user_id",{:user_id => session[:session_user]}])
    @roles = Array.new
    @user_role_map.each do |urmap|
      @roles.push(Role.find(urmap.role_id))
    end
    session[:roles] = @roles
    MadConstants.home_page
  end

  # -> Method takes a splat of permitted roles, the list of
  #    user's roles and the page to be redirected to if no
  #    roles match.
  # -> Validates the user if roles match, otherwise redirects
  #    them.
  def validate_user(*permitted_roles,user_role_list,redirection_page)
    return if (User.has_role(Role.ADMINISTRATOR,user_role_list))
    permitted_roles.each do |role|
      return if (User.has_role(role,user_role_list))
    end
    redirect_to redirection_page, :flash => {:info => MadConstants.permission_denied}
  end

  # -> Following method is to redirect user to 404 error page on misstyping of url
  # -> Reference -->> http://stackoverflow.com/questions/17678087/how-do-i-prevent-unwanted-routing-errors-in-production
  # -> Here see also config/routes.rb file line no. 100
  def redirect_user_404
    redirect_to '/404'
  end
  
  private
end
