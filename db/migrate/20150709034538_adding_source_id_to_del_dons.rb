class AddingSourceIdToDelDons < ActiveRecord::Migration
  def change
    change_table :deleted_donations do |t|
      t.column(:source_id, :integer)
    end
  end
end
