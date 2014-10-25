class ContestResult < ActiveRecord::Base
  belongs_to :user
  belongs_to :contest

  before_save do
    new_total = 0

    scores.each do |_, tasks|
      new_total += Task.find(tasks.select { |_, v| v }.keys).inject(0) do |sum, task|
        sum + task.point
      end
    end

    self.total_score = new_total
  end
end
