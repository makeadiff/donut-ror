class CreateEvents < ActiveRecord::Migration
  def change
    create_table :events do |t|
      t.string :event_name
      t.string :image_url
      t.float :ticket_price
      t.string :description
      t.date :date_range_from
      t.date :date_range_to
      t.string :venue_address
      t.string :venue_address1
      t.integer :city_id
      t.integer :state_id

      t.timestamps
    end
  end
end
