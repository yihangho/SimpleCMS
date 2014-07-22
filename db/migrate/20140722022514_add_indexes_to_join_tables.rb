class AddIndexesToJoinTables < ActiveRecord::Migration
  def change
    add_index :contests_participants, :contest_id
    add_index :contests_participants, :user_id

    add_index :contests_problems, :contest_id
    add_index :contests_problems, :problem_id

    add_index :contests_users, :contest_id
    add_index :contests_users, :user_id

    add_index :solved_problems, :problem_id
    add_index :solved_problems, :user_id

    add_index :solved_tasks, :task_id
    add_index :solved_tasks, :user_id
  end
end
