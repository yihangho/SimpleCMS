class Submission < ActiveRecord::Base
  belongs_to :user
  belongs_to :task

  before_save do
    # Should this part be moved to bg worker?
    # One single such operation should be relatively cheap,
    # but what happens if we have lots of submissions coming in?
    # BTW, we do have a bg worker (sidekiq).
    # It is currently experimental and is available on the sidekiq-bg-worker branch

    self.accepted = correct_input?

    # Cache task solved status
    if user && task
      user.solved_tasks << task if accepted && !user.solved_tasks.include?(task)
      user.save

      if task.problem
        if task.problem.tasks.all? { |t| t.solvers.include?(user) }
          task.problem.solvers |= [user]
        end
      end
    end
  end

  def correct_input?
    input == task.output
  end

  def grade
    update_attribute(:accepted, correct_input?)
    self.accepted
  end

  def cache_all
    grade
    task.cache_solved_status(user)
    task.problem.cache_solved_status(user)
    self.accepted
  end
end
