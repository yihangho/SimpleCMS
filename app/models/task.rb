class Task < ActiveRecord::Base
  has_one :input_file , -> { where :attachmentable_type => "task-input" }, class_name: "Attachment", foreign_key: "attachmentable_id" , validate: false
  has_one :output_file , -> { where :attachmentable_type => "task-output" }, class_name: "Attachment", foreign_key: "attachmentable_id" , validate: false
  belongs_to :problem, :validate => false
  has_many :submissions, :validate => false
  has_and_belongs_to_many :solvers, :class_name => "User", :join_table => "solved_tasks", :validate => false

  def input
    self.input_file.contents
  end

  def input= arg
    if self.input_file
      self.input_file.contents_to_be_uploaded = arg
      self.save
    else
      self.create_input_file contents_to_be_uploaded: arg
    end
  end

  def output
    self.output_file.contents
  end

  def output= arg
    if self.output_file
      self.output_file.contents_to_be_uploaded = arg
      self.save
    else
      self.create_output_file contents_to_be_uploaded: arg
    end
  end

  def correct_answer
    self.output
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
