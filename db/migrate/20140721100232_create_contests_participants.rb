class CreateContestsParticipants < ActiveRecord::Migration
  def change
    create_table :contests_participants, :id => false do |t|
      t.integer :contest_id
      t.integer :user_id
    end
  end
end
