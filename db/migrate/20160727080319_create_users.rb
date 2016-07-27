class CreateUsers < ActiveRecord::Migration[5.0]
  def change
    create_table :users do |t|
      t.string :email
      t.text :subject_settings
      t.string :public_id
      t.boolean :subscribed
      t.boolean :verified

      t.timestamps
    end
  end
end
