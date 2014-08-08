class AddTokensToTasks < ActiveRecord::Migration
  def change
    add_column :tasks, :tokens, :integer, :default => 0
  end
end
