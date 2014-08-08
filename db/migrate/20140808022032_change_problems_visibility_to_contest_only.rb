class ChangeProblemsVisibilityToContestOnly < ActiveRecord::Migration
  class Problem < ActiveRecord::Base
  end

  def change
    add_column :problems, :contest_only, :boolean, :default => true

    reversible do |dir|
      dir.up do
        Problem.reset_column_information
        Problem.all.each do |problem|
          problem.update_attribute(:contest_only, problem.visibility == "contest_only")
        end
      end

      dir.down do
        Problem.reset_column_information
        Problem.all.each do |problem|
          problem.update_attribute(:visibility, problem.contest_only? ? "contest_only" : "public")
        end
      end
    end

    remove_column :problems, :visibility, :string
  end
end
