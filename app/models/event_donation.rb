class EventDonation < ActiveRecord::Base
  belongs_to :event
  belongs_to :donour
  belongs_to :user

  @STATUS_APPROVED_BY_EVENT_HEAD = 'EVENT_DONATION_HAND_OVER_TO_FC_PENDING'
  @STATUS_APPROVED_BY_CFC = 'EVENT_DONATION_DEPOSIT_PENDING'
  @STATUS_APPROVED_BY_NATIONAL_FC = 'EVENT_DONATION_DEPOSIT_COMPLETE'
  @STATUS_TO_BE_APPROVED_BY_EVENT_HEAD ='TO_BE_APPROVED_BY_EVENT_HEAD'

  class << self
    attr_reader :STATUS_APPROVED_BY_CFC,
                :STATUS_APPROVED_BY_EVENT_HEAD,
                :STATUS_TO_BE_APPROVED_BY_EVENT_HEAD,
                :STATUS_APPROVED_BY_NATIONAL_FC
  end

  # -> Method takes the user id of updater, and the
  #    updated status and changes the status of the
  #    event donation which calls the function (self).
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
  #    update status and increments the called event
  #    donation's version by 1 and updates its status.
  def prepare_for_update(updated_by_id, status)
    self.version += 1
    self.updated_by = updated_by_id
    self.donation_status = status
    self.updated_at = Date.current
  end

  # -> Method returns the current event donation 
  #    version of the calling event donation it belongs to.
  def version_donation(donation)
    current_donation_version = EventDonationVersion.new
    current_donation_version.assign_donation_attributes(donation)
    current_donation_version
  end

  # -> Method returns a hash containing the current status and
  #    the post approval status for the role which is passed to
  #    the method.
  def self.get_approval_status_by_role role
    role_status_map = {Role.CITY_FINANCIAL_CONTROLLER => {current_status: EventDonation.STATUS_APPROVED_BY_EVENT_HEAD,post_approval_status: EventDonation.STATUS_APPROVED_BY_CFC},
                       Role.NATIONAL_FINANCIAL_CONTROLLER => {current_status:  EventDonation.STATUS_APPROVED_BY_CFC,post_approval_status: EventDonation.STATUS_APPROVED_BY_NATIONAL_FC},
                       Role.EVENTS_FELLOW => {current_status: EventDonation.STATUS_TO_BE_APPROVED_BY_EVENT_HEAD,post_approval_status: EventDonation.STATUS_APPROVED_BY_EVENT_HEAD}}
    role_status_map[role]
  end
  
  # -> Method returns the event to which the calling
  #    event donation object belongs to.
  # -> Nothing is returned when event id is 0.
  def current_event
    if event_id == 0
      nil
    else
      @event = Event.find(event_id)
    end
  end

  # -> Method returns the ticket price associated with
  #    the calling event donation. 
  def ticket_price
    begin
      ticket_id = self.event_ticket_type_id
      EventTicketType.find(ticket_id.to_i).ticket_price.to_f
    rescue ActiveRecord::RecordNotFound
    end
  end
  
  # -> Method returns the name of the event to which
  #    the calling event donation object belongs to.
  # -> Empty string is returned when there's no associated
  #    event to the event donation.
  def event
    if event_id == 0 || event_id.to_s.upcase == 'NULL'
      ""
    else
      @event = Event.find(event_id)
      @event[:event_name]
    end
  end

  # -> Method returns the donour of the event donation.
  def donour_user
    Donour.find(donour_id)
  end

  # -> Method returns rhe fundraiser of the event donation.
  def fundraiser_user
    User.find(fundraiser_id)
  end

  # -> Method returns all event donations matching a search string passed
  #    to it.
  # -> If no arguments are passed to the method, then all donations 
  #    are returned.
  def self.event_txn_search(search)
    if search
      EventDonation.where("donation_amount LIKE ? OR donation_status LIKE ? 
          OR fundraiser_id in (SELECT ID FROM users where concat(first_name,' ',last_name) LIKE ?) 
          OR donour_id in (SELECT ID FROM donours where concat(first_name,' ',last_name) LIKE ?) 
          OR event_id in (SELECT ID FROM events where event_name LIKE ?)",
                          "%#{search}%", "%#{search}%", "%#{search}%", "%#{search}%", "%#{search}%")
    else
      EventDonation.all
    end
  end
end
