class Task < ActiveRecord::Base
  belongs_to :problem, :validate => false
  has_many :submissions, :validate => false
  has_and_belongs_to_many :solvers, :class_name => "User", :join_table => "solved_tasks", :validate => false

  validates :problem_id, :presence => true

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
