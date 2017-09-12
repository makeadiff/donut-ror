class Donation < ActiveRecord::Base
  
  @STATUS_TO_BE_APPROVED_BY_POC = 'TO_BE_APPROVED_BY_POC'
  @STATUS_APPROVED_BY_POC = 'HAND_OVER_TO_FC_PENDING'
  @STATUS_APPROVED_BY_EVENT_HEAD = 'HAND_OVER_TO_FC_PENDING'
  @STATUS_APPROVED_BY_CFC = 'DEPOSIT_PENDING'
  @STATUS_APPROVED_BY_NATIONAL_FC = 'DEPOSIT COMPLETE'
  @STATUS_EIGHTY_G_RECEIPT_PENDING = 'RECEIPT PENDING'
  @STATUS_EIGHTY_G_RECEIPT_SENT = 'RECEIPT SENT'
  @STATUS_TO_BE_APPROVED_BY_EVENT_HEAD = 'TO_BE_APPROVED_BY_EVENT_HEAD'

  class << self
    attr_reader :STATUS_APPROVED_BY_CFC, 
                :STATUS_APPROVED_BY_POC,
                :STATUS_APPROVED_BY_EVENT_HEAD,
                :STATUS_TO_BE_APPROVED_BY_POC,
                :STATUS_TO_BE_APPROVED_BY_EVENT_HEAD,
                :STATUS_APPROVED_BY_NATIONAL_FC,
                :STATUS_EIGHTY_G_RECEIPT_PENDING,
                :STATUS_EIGHTY_G_RECEIPT_SENT
  end

  belongs_to :user
  belongs_to :donour
  belongs_to :cfr_product
  
  # -> Method takes the user id of updater, and the
  #    updated status and changes the status of the
  #    donation which calls the function (self).
  def change_status(updater_id, updated_status)
    current_donation_version = version_donation(self)
    prepare_for_update(updater_id, updated_status)
    begin
      self.transaction do
        current_donation_version.save
        self.save
      end
    end
  end

  # -> Method takes the user id of updater, and the
  #    update status and increments the called donation's
  #    version by 1 and updates its status.
  def prepare_for_update(updated_by_id, status)
    self.version += 1
    self.updated_by = updated_by_id
    self.donation_status = status
    self.updated_at = Time.now
  end
  
  # -> Method returns the donour of the donation
  def donour_user
    if donour_id then # This is to fix a bug where some entries have been coming in WITHOUT a donor_id. Its 0 in the table. No idea why.
      Donour.find(donour_id)
    else
      Donour.new
    end
  end
  
  # -> Method returns poc user who the fundraiser reports to
  def poc_user
    @poc_user = User.find_by_sql("select u.* from users u join reports_tos rt on (u.id = rt.manager_id) 
          join user_role_maps rm on (rt.manager_id = rm.user_id) join roles r on (r.id = rm.role_id)  
          where rt.user_id = " + fundraiser_id.to_s + " and r.role = '" + Role.CFR_POC.to_s + "'")
    if @poc_user.present?
      @poc_user.to_a.each do |poc_user_found|
        return poc_user_found
      end
    end
  end
  
  # -> Method returns the fundraiser
  def fundraiser_user
    User.find(fundraiser_id)
  end

  # -> Method returns the name of the CFR product the
  #    calling donation belongs to. 
  # -> Method returns an empty string where no product 
  #    is specified.
  def cfr_product
    if product_id == 0
      ""
    else
      @cfr_product = CfrProduct.find(product_id)
      @cfr_product.name
    end
  end

  private

  # -> Method returns the current donation version of the
  #    calling donation it belongs to.
  def version_donation(donation)
    current_donation_version = DonationVersion.new
    current_donation_version.assign_donation_attributes(donation)
    current_donation_version
  end

  # -> Method returns a hash containing the current status and
  #    the post approval status for the role which is passed to
  #    the method.
  def self.get_approval_status_by_role(role)
    role_status_map = {Role.CFR_POC => {current_status: Donation.STATUS_TO_BE_APPROVED_BY_POC ,post_approval_status: Donation.STATUS_APPROVED_BY_POC},
                       Role.CITY_FINANCIAL_CONTROLLER => {current_status: Donation.STATUS_APPROVED_BY_POC,post_approval_status: Donation.STATUS_APPROVED_BY_CFC},
                       Role.NATIONAL_FINANCIAL_CONTROLLER => {current_status:  Donation.STATUS_APPROVED_BY_CFC,post_approval_status: Donation.STATUS_APPROVED_BY_NATIONAL_FC},
                       Role.EVENTS_FELLOW => {current_status: Donation.STATUS_TO_BE_APPROVED_BY_EVENT_HEAD,post_approval_status: Donation.STATUS_APPROVED_BY_EVENT_HEAD}}
    role_status_map[role]
  end

  # -> Method returns a collection of donations where the passed
  #    search string is matched with the name, phone number or the
  #    email id of all donours. 
  # -> Returns all donations when no argument is passed.
  def self.search(search = nil)
    if search
      Donation.where(:donour_id => Donour.select("id").where("concat(first_name,' ',last_name) LIKE ? 
              OR phone_no LIKE ? OR email_id LIKE ?", "%#{search}%", "%#{search}%", "%#{search}%"))
    else
      Donation.all
    end
  end
  
  # -> Method returns all donations created in the date range passed
  #    to it.
  # -> If no arguments are passed (or only one is passed), then 
  #    returns all donations.
  def self.date_range_search(from_date_range = nil, to_date_range = nil)
    if from_date_range && to_date_range
      Donation.where("created_at >= ? AND created_at <= ?", 
                "%#{from_date_range}%", "%#{to_date_range}%")
    else
      Donation.all
    end
  end
  
  # -> Method returns all donations matching a search string passed
  #    to it. The search is much thorough than Donation.search method.
  # -> If no arguments are passed to the method, then all donations 
  #    are returned.
  def self.cfr_txn_search(search = nil)
    if search
      Donation.where("donation_type LIKE ? OR donation_amount LIKE ? OR donation_status LIKE ?
          OR fundraiser_id in (SELECT ID FROM users where concat(first_name,' ',last_name) LIKE ?) 
          OR donour_id in (SELECT ID FROM donours where concat(first_name,' ',last_name) LIKE ?) 
          OR product_id in (SELECT ID FROM cfr_products where name LIKE ?)",
                     "%#{search}%", "%#{search}%", "%#{search}%", "%#{search}%", "%#{search}%", "%#{search}%")
    else
      Donation.all
    end
  end
end
