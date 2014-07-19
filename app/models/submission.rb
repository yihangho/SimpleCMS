class Submission < ActiveRecord::Base
  belongs_to :user
  belongs_to :task

  def correct_input?
    input == task.output
  end

  def grade
    self.accepted = correct_input?
  end
end
