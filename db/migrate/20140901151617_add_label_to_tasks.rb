class AddLabelToTasks < ActiveRecord::Migration
  def change
    add_column :tasks, :label, :string, :default => ""
  end
end
