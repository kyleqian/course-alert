class AddLastUpdateSentToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :last_update_sent, :datetime
  end
end
