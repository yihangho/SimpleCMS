class DestroySolvedProblems < ActiveRecord::Migration
  def up
    drop_table :solved_problems
  end

  def down
    create_table :solved_problems, :id => false do |t|
      t.integer :problem_id
      t.integer :user_id
    end

    add_index :solved_problems, :problem_id
    add_index :solved_problems, :user_id
  end
end
