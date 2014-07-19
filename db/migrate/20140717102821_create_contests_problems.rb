class CreateContestsProblems < ActiveRecord::Migration
  def change
    create_table :contests_problems, :id => false do |t|
      t.integer :contest_id
      t.integer :problem_id

      t.index [:contest_id, :problem_id]
    end
  end
end
