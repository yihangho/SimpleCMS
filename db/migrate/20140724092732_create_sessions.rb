class CreateSessions < ActiveRecord::Migration
  def change
    create_table :sessions do |t|
      t.string :remember_token
      t.integer :user_id
      t.string :user_agent

      t.index :remember_token, :unique => true
      t.index [:remember_token, :user_id]
      t.index [:user_id, :remember_token]

      t.timestamps
    end
  end
end
