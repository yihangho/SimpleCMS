class Submission < ActiveRecord::Base
  scope :correct_answer, -> { where(:accepted => true) }
  scope :by, ->(user) { where(:user_id => user) }
  scope :for, ->(task) { where(:task_id => task) }

  belongs_to :user, :validate => false
  belongs_to :task, :validate => false

  validates :user_id, :task_id, :presence => true

  before_save do
    grade

    true
  end

  after_save do
    # Update solve status
    solve_status = user.solve_statuses.where(:problem_id => task.problem).first

    unless solve_status
      solve_status = user.solve_statuses.create(:problem_id => task.problem.id)
    end

    solve_status.tasks[task.id.to_s] ||= []

    if accepted?
      solve_status.tasks[task.id.to_s] << id unless solve_status.tasks[task.id.to_s].include?(id)
    else
      solve_status.tasks[task.id.to_s].delete(id)
      solve_status.tasks[task.id.to_s] = false if solve_status.tasks[task.id.to_s].empty?
    end

    solve_status.save

    # Update contest results
    ongoing_contests = task.problem.contests.
                        where(Contest.arel_table[:end].gt(created_at)).
                        where(:id => user.participated_contests)

    ongoing_contests.each do |contest|
      contest_result = user.contest_results.where(:contest_id => contest).first
      contest_result = user.contest_results.create(:contest_id => contest.id) unless contest_result

      contest_result.scores[task.problem.id.to_s]               ||= {}
      task_arr = (contest_result.scores[task.problem.id.to_s][task.id.to_s] ||= [])

      if accepted?
        task_arr << id unless task_arr.include?(id)
      else
        task_arr.delete(id)
        contest_result.scores[task.problem.id.to_s][task.id.to_s] = false if task_arr.empty?
      end

      contest_result.save
    end
  end

  def grade
    self.accepted = task.grade(input, user)
  end
end
