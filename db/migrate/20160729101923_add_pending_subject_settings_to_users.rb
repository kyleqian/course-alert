class AddPendingSubjectSettingsToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :pending_subject_settings, :text
  end
end
