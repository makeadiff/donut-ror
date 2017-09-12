class AddUpdatedByToDonations < ActiveRecord::Migration
  def change
    add_column :donations, :updated_by, :integer
  end
end
