class MobileApprovalsController < ActionController::Base
  @basicauth = BasicAuth.first()
  
  http_basic_authenticate_with :name => @basicauth.name, :password => @basicauth.password
  skip_before_filter :verify_authenticity_token
  
  before_action :set_event, only: [:show]

  # GET /events/1
  # GET /events/1.json
  def show
    format.xml {
      render :xml
    }
  end

  # TO_BE_APPROVED_BY_POC > HAND_OVER_TO_FC_PENDING > DEPOSIT_PENDING
  # TO_BE_APPROVED_BY_EVENT_HEAD > EVENT_DONATION_HAND_OVER_TO_FC_PENDING > EVENT_DONATION_DEPOSIT_PENDING 


  # http://localhost:3000/mobile_approvals/donations_to_be_approved_by_poc?volunteer_id=3152&format=xml
  def donations_to_be_approved_by_poc
        # Test using 3152
    roles = UserRoleMap.getRoleidByUserid(params[:volunteer_id])
    role_match = false

    roles.each do |r|
      role_match = true if r.role_id == 9 # Make sure the user is a POC
    end

    if role_match
      @donations = Donation.where(:donation_status => 'TO_BE_APPROVED_BY_POC',
            :fundraiser_id => ReportsTo.select("user_id").where(:manager_id => params[:volunteer_id]))
    else
      @donations = nil
    end

    respond_to do |format|
      format.xml
    end
  end

  def poc_approve_donation
    # Only FCs can access this 
    @roles = UserRoleMap.getRolesByUserid(params[:approver_id])
    unless User.has_role Role.CFR_POC, @roles
      return
    end

    @donation = Donation.where(:id => params[:donation_id], :donation_status => 'TO_BE_APPROVED_BY_POC',
                  :fundraiser_id => ReportsTo.select("user_id").where(:manager_id => params[:approver_id])).first

    @donation.assign_attributes({:donation_status => 'HAND_OVER_TO_FC_PENDING', 
                                    :updated_at => Time.now,
                                    :updated_by => params[:approver_id]})
    @donation.save

    respond_to do |format|
      format.xml
    end
  end

  def fc_approve_handover
    # Only FCs can access this 
    @roles = UserRoleMap.getRolesByUserid(params[:approver_id])
    unless User.has_role Role.CITY_FINANCIAL_CONTROLLER, @roles
      return
    end

    @donation = Donation.where(:id => params[:donation_id], :donation_status => 'HAND_OVER_TO_FC_PENDING',
                  :updated_by => ReportsTo.select("user_id").where(:manager_id => params[:approver_id])).first

    @donation.assign_attributes({:donation_status => 'DEPOSIT_PENDING',
                                  :updated_at => Time.now,
                                  :updated_by => params[:approver_id]})
    @donation.save

    respond_to do |format|
      format.xml
    end
  end

  # This will return all the donations that should be handed over to the FC(whose ID is given as an argument).
  #   The donations will be clubbed by the POC
  # localhost:3000/mobile_approvals/donations_grouped_by_poc?fc_id=2973&format=xml
  def donations_grouped_by_poc
    # Only FCs can access this 
    @roles = UserRoleMap.getRolesByUserid(params[:fc_id])
    
    unless User.has_role Role.CITY_FINANCIAL_CONTROLLER, @roles
      return
    end

    @approver= User.find(params[:fc_id]) if @approver.nil?
    @approver.set_current_user_role_map @roles
    donation_status_by_role = Donation.get_approval_status_by_role @approver.current_role

    puts @approver.inspect
    puts donation_status_by_role.inspect

    @subordinates=[]
    @approver.subordinates.each do |subordinate|
      total_amount_of_donations = subordinate.total_amount_of_donations(donation_status_by_role[:current_status])
      unless total_amount_of_donations == 0
        subordinate.total_donation_amount =  total_amount_of_donations
        @subordinates.push subordinate
      end
    end

    respond_to do |format|
      format.xml
    end
  end

end