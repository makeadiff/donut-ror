class AddCityIdToGroups < ActiveRecord::Migration
  def change
    add_column :groups, :city_id, :integer
  end
end
