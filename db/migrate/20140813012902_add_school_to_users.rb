class AddSchoolToUsers < ActiveRecord::Migration
  def change
    add_column :users, :school, :string
    add_index  :users, :school
  end
end
