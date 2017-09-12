class CreateDonours < ActiveRecord::Migration
  def change
    create_table :donours do |t|
      t.string :first_name
      t.string :last_name
      t.string :email_id
      t.string :phone_no
      t.string :address

      t.timestamps
    end
  end
end
