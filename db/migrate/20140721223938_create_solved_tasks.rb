class CreateSolvedTasks < ActiveRecord::Migration
  def change
    create_table :solved_tasks, :id => false do |t|
      t.integer :task_id
      t.integer :user_id
    end
  end
end
