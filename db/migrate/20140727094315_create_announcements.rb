class CreateAnnouncements < ActiveRecord::Migration
  def change
    create_table :announcements do |t|
      t.string :title
      t.text :message
      t.integer :sender_id
      t.integer :contest_id

      t.index :contest_id

      t.timestamps
    end
  end
end
