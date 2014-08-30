class UpdateTasks < ActiveRecord::Migration
  # Prepare the Task model for randomized test cases:
  # 1. Rename input to input_generator
  # 2. Rename output to grader
  # 3. Remove JSON
  def change
    rename_column :tasks, :input, :input_generator
    rename_column :tasks, :output, :grader
    remove_column :tasks, :json, :boolean
  end
end
