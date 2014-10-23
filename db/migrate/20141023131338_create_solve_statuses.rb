class CreateSolveStatuses < ActiveRecord::Migration
  def change
    create_table :solve_statuses do |t|
      t.references :user, :null => false
      t.references :problem, :null => false
      t.json :tasks, :default => {}, :null => false

      t.index [:user_id, :problem_id], :unique => true
      t.index [:problem_id, :user_id], :unique => true

      t.timestamps
    end
  end
end
