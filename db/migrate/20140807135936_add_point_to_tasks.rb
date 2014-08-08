class AddPointToTasks < ActiveRecord::Migration
  def change
    add_column :tasks, :point, :integer
  end
end
