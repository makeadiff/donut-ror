class DonationVersion < ActiveRecord::Base

  # -> Donation object is passed to the method, which is then
  #    used to assign the attributes of the calling 
  #    DonationVersion object. 
  def assign_donation_attributes(donation)
    self.assign_attributes(:donation_type => donation.donation_type,
                           :version => donation.version,
                           :fundraiser_id => donation.fundraiser_id,
                           :donour_id => donation.donour_id,
                           :donation_status => donation.donation_status,
                           :eighty_g_required => donation.eighty_g_required,
                           :product_id => donation.product_id,
                           :donation_amount => donation.donation_amount,
                           :updated_by => donation.updated_by,
                           :created_at => donation.created_at,
                           :updated_at => donation.updated_at,
                           :donation_id => donation.id)
  end
end
