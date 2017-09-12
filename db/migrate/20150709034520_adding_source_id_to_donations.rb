class AddingSourceIdToDonations < ActiveRecord::Migration
  def change
    change_table :donations do |t|
      t.column(:source_id, :integer)
    end
  end
end
