class Task < ActiveRecord::Base
  belongs_to :problem, :validate => false
  has_many :submissions, :validate => false
  has_and_belongs_to_many :solvers, :class_name => "User", :join_table => "solved_tasks", :validate => false

  def solved_by?(user)
    solvers.include?(user)
  end

  def solved_between_by?(time1, time2, user)
    user.submissions.where(:task_id => id, :created_at => (time1..time2), :accepted => true).any?
  end

  def attempted_by?(user)
    user.submissions.where("task_id = #{id}").any?
  end
end
