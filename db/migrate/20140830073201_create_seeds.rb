class CreateSeeds < ActiveRecord::Migration
  def change
    create_table :seeds do |t|
      t.string :seed
      t.integer :user_id
      t.integer :task_id

      t.index [:user_id, :task_id], :unique => true
      t.index [:task_id, :user_id], :unique => true

      t.timestamps
    end
  end
end
