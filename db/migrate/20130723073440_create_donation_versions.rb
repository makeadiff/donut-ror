class CreateDonationVersions < ActiveRecord::Migration
  def change
    create_table :donation_versions do |t|
      t.string :donation_type
      t.integer :version
      t.integer :fundraiser_id
      t.integer :donour_id
      t.string :donation_status
      t.boolean :eighty_g_required
      t.integer :product_id
      t.float :donation_amount
      t.integer :updated_by

      t.timestamps
    end
  end
end
