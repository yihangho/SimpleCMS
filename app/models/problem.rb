class Problem < ActiveRecord::Base
  validates :title, :statement, :presence => true
  has_one :permalink, :as => :linkable, :dependent => :destroy
  belongs_to :setter, :class_name => "User", :validate => false
  has_many :tasks, :dependent => :destroy, :validate => false
  has_many :codes
  has_and_belongs_to_many :contests, :validate => false
  has_and_belongs_to_many :solvers, :class_name => "User", :join_table => "solved_problems", :validate => false

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
      user.participated_contests.where("\"contests\".\"start\" <= ?", Time.now).any?
    end
  end

  def solved_by?(user)
    solvers.include?(user)
  end

  def solved_between_by?(time1, time2, user)
    tasks.all? { |task| task.solved_between_by?(time1, time2, user) }
  end

  def attempted_by?(user)
    tasks.any? { |task| task.attempted_by?(user) }
  end

  def update_solvers
    task_ids = self.task_ids
    self.solvers = User.select do |user|
      task_ids.all? { |id| user.submissions.for(id).correct_answer.any? }
    end
  end

  def last_submissions_by(user)
    user ||= User.new
    tasks.collect do |task|
      [task.id, user.submissions.for(task).last]
    end.to_h
  end

  def total_points
    tasks.inject(0) { |sum, task| sum + task.point }
  end

  def points_for(user)
    tasks.inject(0) do |sum, task|
      task.solved_by?(user) ? sum + task.point : sum
    end
  end

  def points_for_between(user, time1, time2)
    tasks.inject(0) do |sum, task|
      task.solved_between_by?(time1, time2, user) ? sum + task.point : sum
    end
  end

  def to_h(user = User.new)
    user ||= User.new
    hash = attributes.dup
    hash[:tasks_attributes] = tasks.map { |task| task.to_h(user) }
    hash[:permalink_attributes] = permalink
    hash[:solved] = solved_by?(user)
    hash[:attempted] = attempted_by?(user)
    hash[:total_points] = total_points
    hash[:points_scored] = points_for(user)
    if errors.any?
      hash[:errors] = errors.full_messages
    end
    hash
  end
end
