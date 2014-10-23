class CreateContestResults < ActiveRecord::Migration
  def change
    create_table :contest_results do |t|
      t.references :user, :null => false
      t.references :contest, :null => false
      t.json :scores, :default => {}, :null => false
      t.integer :total_score, :default => 0

      t.index :user_id
      t.index [:contest_id, :total_score]

      t.timestamps
    end
  end
end
