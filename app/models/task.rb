class Task < ActiveRecord::Base
  has_one :input_file , -> { where :attachmentable_type => "task-input" }, class_name: "Attachment", foreign_key: "attachmentable_id" , validate: false , autosave: true
  has_one :output_file , -> { where :attachmentable_type => "task-output" }, class_name: "Attachment", foreign_key: "attachmentable_id" , validate: false , autosave: true
  belongs_to :problem, :validate => false
  has_many :submissions, :validate => false
  has_and_belongs_to_many :solvers, :class_name => "User", :join_table => "solved_tasks", :validate => false

  def input
    self.input_file ? self.input_file.contents : nil
  end

  def input= arg
    # MEMO => normalize the input here eg: arg = arg.normalize
    self.create_input_file if self.input_file.nil?
    self.input_file.upload arg
    self.input_file.save
  end

  def output
    self.output_file ? self.output_file.contents : nil
  end

  def output= arg
    self.create_output_file if self.output_file.nil?
    self.output_file.upload arg
    self.output_file.save
  end

  def solved_by?(user)
    solvers.include?(user)
  end

  def solved_between_by?(time1, time2, user)
    user.submissions.where(:task_id => id, :created_at => (time1..time2), :accepted => true).any?
  end

  def attempted_by?(user)
    user.submissions.where("task_id = #{id}").any?
  end

  def regrade
    # 1. Update the accepted column for all submissions of this task
    # 2. Update the list of solvers

    submissions.each do |submission|
      submission.update_attribute(:accepted, submission.correct_input?)
    end

    self.solvers = User.select do |user|
      user.submissions.for(self).correct_answer.any?
    end
  end
end
