class CreateTasks < ActiveRecord::Migration
  def change
    create_table :tasks do |t|
      t.text :input
      t.text :output
      t.integer :problem_id

      t.index :problem_id

      t.timestamps
    end
  end
end
