class Problem < ActiveRecord::Base
  validates :title, :statement, :presence => true
  has_one :permalink, :as => :linkable, :dependent => :destroy
  belongs_to :setter, :class_name => "User", :validate => false
  has_many :tasks, :dependent => :destroy, :validate => false
  has_many :codes
  has_and_belongs_to_many :contests, :validate => false
  has_many :solve_statuses

  validates_associated :tasks

  accepts_nested_attributes_for :tasks, :allow_destroy => true
  accepts_nested_attributes_for :permalink, :update_only => true, :reject_if => :all_blank, :allow_destroy => true

  scope :contest_problems, -> { where(:contest_only => true) }

  def visible_to?(user)
    user ||= User.new(:admin => false)

    if !contest_only?
      true
    elsif user.admin?
      true
    else
      user.participated_contests.where(:id => contests).where("\"contests\".\"start\" <= ?", Time.now).any?
    end
  end

  def solved_by?(user)
    solve_status = user.solve_statuses.where(:problem_id => id).first
    solve_status && solve_status.tasks.select { |_, v| v }.keys.map(&:to_i).sort == task_ids.sort
  end

  def attempted_by?(user)
    user.submissions.where(:task_id => tasks).any?
  end

  def last_submissions_by(user)
    user.submissions.where(:task_id => tasks).last
  end

  def total_points
    tasks.inject(0) { |sum, task| sum + task.point }
  end

  def points_for(user)
    solve_status = user.solve_statuses.where(:problem_id => id).first
    solve_status && solve_status.tasks.select { |_, v| v }.keys.inject(0) do |sum, id|
      sum + Task.find(id).point
    end
  end

  def submissions
    Submission.where(:task_id => tasks)
  end
end
