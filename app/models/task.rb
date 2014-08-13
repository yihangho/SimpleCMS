class Task < ActiveRecord::Base
  has_one :input_file , -> { where :attachmentable_type => "task-input" , :active => true }, class_name: "Attachment", foreign_key: "attachmentable_id" , validate: false , autosave: true
  has_one :output_file , -> { where :attachmentable_type => "task-output" , :active => true }, class_name: "Attachment", foreign_key: "attachmentable_id" , validate: false , autosave: true
  belongs_to :problem, :validate => false
  has_many :submissions, :validate => false
  has_and_belongs_to_many :solvers, :class_name => "User", :join_table => "solved_tasks", :validate => false

  validates :problem_id, :presence => true
  validates :point, :numericality => { :greater_than_or_equal_to => 0, :only_integer => true }

  after_initialize do
    self.point ||= 0
  end

  def input
    self.input_file ? self.input_file.contents : nil
  end

  def input= arg
    # MEMO => normalize the input here eg: arg = arg.normalize
    self.build_input_file if self.input_file.nil?
    self.input_file.upload arg
  end

  def output
    self.output_file ? self.output_file.contents : nil
  end

  def output= arg
    self.build_output_file if self.output_file.nil?
    self.output_file.upload arg
  end

  def solved_by?(user)
    solvers.include?(user)
  end

  def solved_between_by?(time1, time2, user)
    user.submissions.for(self).correct_answer.where(:created_at => (time1..time2)).any?
  end

  def attempted_by?(user)
    user.submissions.for(self).any?
  end

  def regrade
    submissions.each do |submission|
      submission.regrade
    end

    update_solvers
    problem.update_solvers
  end
end

def update_solvers
  self.solvers = User.select do |user|
    user.submissions.for(self).correct_answer.any?
  end
end
