class AddDonationIdToDonationVersion < ActiveRecord::Migration
  def change
    add_column :donation_versions, :donation_id, :integer
  end
end
