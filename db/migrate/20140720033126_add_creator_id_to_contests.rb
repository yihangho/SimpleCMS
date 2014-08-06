class AddCreatorIdToContests < ActiveRecord::Migration
  def change
    add_column :contests, :creator_id, :integer
    add_index  :contests, :creator_id
  end
end
