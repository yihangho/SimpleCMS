class CreateSolvedProblems < ActiveRecord::Migration
  def change
    create_table :solved_problems, :id => false do |t|
      t.integer :problem_id
      t.integer :user_id
    end
  end
end
