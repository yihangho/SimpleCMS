class CreatePermalinks < ActiveRecord::Migration
  def change
    create_table :permalinks do |t|
      t.string :url
      t.integer :linkable_id
      t.string :linkable_type

      t.timestamps

      t.index :url, :unique => true
      t.index [:linkable_type, :linkable_id]
    end
  end
end
