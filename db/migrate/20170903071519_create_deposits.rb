class CreateDeposits < ActiveRecord::Migration
  def change
    create_table :deposits do |t|
      t.integer :collected_from_user_id
      t.integer :given_to_user_id
      t.datetime :added_on
      t.datetime :reviewed_on
      t.decimal :amount
      t.string :status, default: "pending"

      t.timestamps
    end
  end
end
