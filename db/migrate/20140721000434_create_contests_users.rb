class CreateContestsUsers < ActiveRecord::Migration
  def change
    create_table :contests_users, :id => false do |t|
      t.integer :contest_id
      t.integer :user_id
    end
  end
end
