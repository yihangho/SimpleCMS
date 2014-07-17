class CreateSubmissions < ActiveRecord::Migration
  def change
    create_table :submissions do |t|
      t.integer :user_id
      t.integer :task_id
      t.text :input

      t.timestamps
    end
  end
end
