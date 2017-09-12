class CreateRoleReportTos < ActiveRecord::Migration
  def change
    create_table :role_report_tos do |t|
      t.integer :user_role_id
      t.integer :manager_role_id

      t.timestamps
    end
  end
end
