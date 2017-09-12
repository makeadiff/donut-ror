class DeletedDonation < ActiveRecord::Base

  def self.save_backup_copy(donation, user_id)
    self.assign_attributes({
      :id => donation.id,
      :donation_type => donation.donation_type,
      :version => donation.version,
      :fundraiser_id => donation.fundraiser_id,
      :donour_id => donation.donour_id,
      :donation_status => donation.donation_status,
      :eighty_g_required => donation.eighty_g_required,
      :product_id => donation.product_id,
      :donation_amount => donation.donation_amount,
      :updated_by => user_id,
      :created_at => donation.created_at,
      :updated_at => Date.current})
    self.save

    self.id = donation.id
    self.donation_type = donation.donation_type
    self.version = donation.version
    self.fundraiser_id = donation.fundraiser_id
    self.donour_id = donation.donour_id
    self.donation_status = donation.donation_status
    self.eighty_g_required = donation.eighty_g_required
    self.product_id = donation.product_id
    self.donation_amount = donation.donation_amount
    self.updated_by = user_id
    self.created_at = donation.created_at
    self.updated_at = Date.current
    self.save
  end
end
