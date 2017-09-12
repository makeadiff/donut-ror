class CreateCfrProducts < ActiveRecord::Migration
  def change
    create_table :cfr_products do |t|
      t.string :name
      t.string :description
      t.float :target
      t.integer :city_id
      t.string :image_logo

      t.timestamps
    end
  end
end
