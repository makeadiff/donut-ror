class AddCommentsToDonations < ActiveRecord::Migration
  def change
  		add_column :donations, :comment, :string
  end
end
