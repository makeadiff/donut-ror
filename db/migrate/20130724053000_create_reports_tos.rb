class CreateReportsTos < ActiveRecord::Migration
  def change
    create_table :reports_tos ,:id => false do |t|
      t.integer :user_id
      t.integer :manager_id

      t.timestamps
    end
    add_index :reports_tos , [:user_id,:manager_id] , unique:true
  end
end
