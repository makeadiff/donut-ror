class CreateEventVolunteerMaps < ActiveRecord::Migration
  def change
    create_table :event_volunteer_maps do |t|
      t.integer :volunteer_id
      t.integer :event_id

      t.timestamps
    end
  end
end
