class Submission < ActiveRecord::Base
  scope :correct_answer, -> { where(:accepted => true) }
  scope :by, ->(user) { where(:user_id => user) }
  scope :for, ->(task) { where(:task_id => task) }

  belongs_to :user, :validate => false
  belongs_to :task, :validate => false

  validates :user_id, :task_id, :presence => true

  before_save do
    self.accepted = task.grade(input, user)

    true
  end

  after_save do
    solve_status = user.solve_statuses.where(:problem_id => task.problem).first

    unless solve_status
      solve_status = user.solve_statuses.create(:problem_id => task.problem.id)
    end

    solve_status.tasks[task.id] ||= []

    if accepted?
      solve_status.tasks[task.id] << id unless solve_status.tasks[task.id].include?(id)
    else
      solve_status.tasks[task.id].delete(id)
      solve_status.tasks[task.id] = false if solve_status.tasks[task.id].empty?
    end

    solve_status.save
  end
end
