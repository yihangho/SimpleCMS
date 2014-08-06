class Submission < ActiveRecord::Base
  scope :correct_answer, -> { where(:accepted => true) }
  scope :by, ->(user) { where(:user_id => user) }
  scope :for, ->(task) { where(:task_id => task) }

  belongs_to :user, :validate => false
  belongs_to :task, :validate => false

  validates :user_id, :task_id, :presence => true

  after_create do
    update_attribute(:accepted, correct_input?)

    if accepted
      task.solvers << user unless task.solvers.include?(user)

      if !task.problem.solved_by?(user) && task.problem.tasks.all? { |task| task.solvers.include?(user) }
        task.problem.solvers << user
      end
    end
  end

  def correct_input?
    input == task.output
  end
end
