class AddVisibilityToProblems < ActiveRecord::Migration
  def change
    add_column :problems, :visibility, :string
  end
end
