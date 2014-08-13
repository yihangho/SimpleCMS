class RemoveInputOutputFileColumnFromTasks < ActiveRecord::Migration
  def change
  	remove_column :tasks , :input_file
  	remove_column :tasks , :output_file
  end
end
