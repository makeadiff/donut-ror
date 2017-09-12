class EventDonationVersion < ActiveRecord::Base
  def assign_donation_attributes(donation)
    self.assign_attributes(
    	:donation_type => donation.donation_type, 
    	:version => donation.version, 
    	:fundraiser_id => donation.fundraiser_id, 
    	:donour_id => donation.donour_id, 
    	:donation_status => donation.donation_status, 
    	:event_id => donation.event_id,
    	:donation_amount => donation.donation_amount, 
    	:updated_by => donation.updated_by,
    	:created_at => donation.created_at,
    	:updated_at => donation.updated_at,
    	:donation_id => donation.id)
  end
end
