class CreateDepositDonationsJoinTable < ActiveRecord::Migration
  def change
  	create_join_table :deposits, :donations

  	create_join_table :deposits, :donations do |t|
	  t.index :deposit_id
	  t.index :donation_id
	end
  end
end
