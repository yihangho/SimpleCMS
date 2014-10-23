class DestroySolvedTasks < ActiveRecord::Migration
  def up
    drop_table :solved_tasks
  end

  def down
    create_table :solved_tasks, :id => false do |t|
      t.integer :task_id
      t.integer :user_id
    end

    add_index :solved_tasks, :task_id
    add_index :solved_tasks, :user_id
  end
end
