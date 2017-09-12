class AddIsOtherProductToCfrProducts < ActiveRecord::Migration
  def change
    add_column :cfr_products, :is_other_product, :boolean
  end
end
