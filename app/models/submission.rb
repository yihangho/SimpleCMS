class Submission < ActiveRecord::Base
  belongs_to :user
  belongs_to :task

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
