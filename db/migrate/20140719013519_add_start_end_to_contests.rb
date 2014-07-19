class AddStartEndToContests < ActiveRecord::Migration
  def change
    add_column :contests, :start, :datetime
    add_column :contests, :end, :datetime
  end
end
