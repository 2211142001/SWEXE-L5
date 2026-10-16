class CreateProfiles < ActiveRecord::Migration[8.1]
  def change
    create_table :profiles do |t|
      t.string :message
      t.integer :user_id

      t.timestamps
    end
  end
end
