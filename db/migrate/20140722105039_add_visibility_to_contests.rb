class AddVisibilityToContests < ActiveRecord::Migration
  def change
    add_column :contests, :visibility, :string
  end
end
