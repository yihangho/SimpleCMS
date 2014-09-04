class AddStubToProblems < ActiveRecord::Migration
  def change
    add_column :problems, :stub, :text
  end
end
