class CreateBasicAuths < ActiveRecord::Migration
  def change
    create_table :basic_auths do |t|
      t.string :name
      t.string :password

      t.timestamps
    end
  end
end
