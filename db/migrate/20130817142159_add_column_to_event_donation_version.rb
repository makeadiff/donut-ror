class AddColumnToEventDonationVersion < ActiveRecord::Migration
  def change
    add_column :event_donation_versions, :donation_id, :integer
  end
end
