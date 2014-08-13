class RemoveInputFromSubmissionsTable < ActiveRecord::Migration
  def change
    remove_column :submissions , :input
  end
end
