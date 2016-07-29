class AddIndicesToUserPidAndEmail < ActiveRecord::Migration[5.0]
  def change
    add_index :users, :email
    add_index :users, :public_id
  end
end
