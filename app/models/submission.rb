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
  end

  def grade
    self.accepted = task.grade(input, user)
  end
end
