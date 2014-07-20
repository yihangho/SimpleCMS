class Task < ActiveRecord::Base
  belongs_to :problem
  has_many :submissions

  def solved_by?(user)
    !user.submissions.where("task_id = #{id}").none? { |x| x.accepted? }
  end

  def attempted_by?(user)
    user.submissions.where("task_id = #{id}").any?
  end
end
