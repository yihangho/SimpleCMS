class AddColumnForInputOuputToTask < ActiveRecord::Migration
  def change
  	add_column :tasks , :input_file_id , :integer
  	add_column :tasks , :ouput_file_id , :integer
  end
end
