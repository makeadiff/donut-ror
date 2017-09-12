class AddEndDateToCfrProducts < ActiveRecord::Migration
  def change
    add_column :cfr_products, :end_date, :datetime
  end
end
