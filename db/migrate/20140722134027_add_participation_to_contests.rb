class AddParticipationToContests < ActiveRecord::Migration
  def change
    add_column :contests, :participation, :string
  end
end
