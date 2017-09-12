class AddingSourceIdToEventDonations < ActiveRecord::Migration
  def change
    change_table :event_donations do |t|
      t.column(:source_id, :integer)
    end
  end
end
