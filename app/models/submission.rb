class Submission < ActiveRecord::Base
  has_one :attachment , -> { where :attachmentable_type => "submission" , :active => true }, class_name: "Attachment", foreign_key: "attachmentable_id" , validate: false , autosave: true
  scope :correct_answer, -> { where(:accepted => true) }
  scope :by, ->(user) { where(:user_id => user) }
  scope :for, ->(task) { where(:task_id => task) }

  belongs_to :user, :validate => false
  belongs_to :task, :validate => false

  validates :user_id, :task_id, :presence => true

  after_create do
    regrade

    if accepted
      task.solvers << user unless task.solvers.include?(user)

      if !task.problem.solved_by?(user) && task.problem.tasks.all? { |task| task.solvers.include?(user) }
        task.problem.solvers << user
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

  def regrade
    update_attribute(:accepted, correct_input?)
  end
end

