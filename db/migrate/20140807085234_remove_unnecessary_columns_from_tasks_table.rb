class RemoveUnnecessaryColumnsFromTasksTable < ActiveRecord::Migration
  def change
    remove_column :tasks , :input
    remove_column :tasks , :input_file_id
    remove_column :tasks , :output
    remove_column :tasks , :ouput_file_id
  end
end
