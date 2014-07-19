class AddSetterIdToProblems < ActiveRecord::Migration
  def change
    add_column :problems, :setter_id, :integer

    add_index :problems, :setter_id
  end
end
