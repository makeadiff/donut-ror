class AddStartDateToCfrProducts < ActiveRecord::Migration
  def change
    add_column :cfr_products, :start_date, :datetime
  end
end
