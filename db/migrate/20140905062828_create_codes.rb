class CreateCodes < ActiveRecord::Migration
  def change
    create_table :codes do |t|
      t.integer :user_id
      t.integer :problem_id
      t.text :code

      t.index [:user_id, :problem_id]
      t.index [:problem_id, :user_id]

      t.timestamps
    end
  end
end
