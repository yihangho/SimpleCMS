class Submission < ActiveRecord::Base
  has_one :attachment , -> { where :attachmentable_type => "submission" , :active => true }, class_name: "Attachment", foreign_key: "attachmentable_id" , validate: false , autosave: true
  scope :correct_answer, -> { where(:accepted => true) }
  scope :by, ->(user) { where(:user_id => user) }
  scope :for, ->(task) { where(:task_id => task) }

  belongs_to :user, :validate => false
  belongs_to :task, :validate => false

  before_save do
    # Should this part be moved to bg worker?
    # One single such operation should be relatively cheap,
    # but what happens if we have lots of submissions coming in?
    # BTW, we do have a bg worker (sidekiq).
    # It is currently experimental and is available on the sidekiq-bg-worker branch

    self.accepted = correct_input?

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

  def input
    return @cache_input unless @cache_input.nil?
    self.attachment ? self.attachment.contents : nil
  end

  def input= arg
    # memo => NORMALIZE THE INPUT HERE , eg: @cache_input = normalize(arg) , INPUT caching here too , after normalizing
    self.build_attachment if self.attachment.nil?
    self.attachment.upload arg
  end

  def correct_input?
    input == task.output
  end
end

