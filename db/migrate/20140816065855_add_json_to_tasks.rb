class AddJsonToTasks < ActiveRecord::Migration
  def change
    add_column :tasks, :json, :boolean, :default => false
  end
end
