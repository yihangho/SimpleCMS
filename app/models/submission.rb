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

    # As of Rails 4.1.6, it is necessary to make a copy of .tasks and then copy it back
    # by either using solve_status.tasks = tasks or .update_attribute.
    # The reason behind is that ActiveModel tracks changes by rigging the attribute writer,
    # but doing .tasks[something] = something does not go through the writer, hence,
    # ActiveModel will not know that .tasks is changed. As a result, doing a
    # .save or .update_attribute without doing .tasks.dup will not update .tasks.
    #
    # TODO Check if this happens in Rails 4.2
    tasks = solve_status.tasks.dup
    tasks[task.id] ||= []

    if accepted?
      tasks[task.id] << id unless tasks[task.id].include?(id)
    else
      tasks[task.id].delete(id)
      tasks[task.id] = false if tasks[task.id].empty?
    end

    solve_status.update_attribute(:tasks, tasks)
  end
end
