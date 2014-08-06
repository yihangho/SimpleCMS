class AddInstructionsToContests < ActiveRecord::Migration
  def change
    add_column :contests, :instructions, :text
  end
end
