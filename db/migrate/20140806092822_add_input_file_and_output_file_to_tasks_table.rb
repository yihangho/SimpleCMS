class AddInputFileAndOutputFileToTasksTable < ActiveRecord::Migration
  def change
  	add_column :tasks , :input_file , :string
  	add_column :tasks , :output_file , :string
  end
end
