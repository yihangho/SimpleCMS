class Contest < ActiveRecord::Base
  validates :title, :start, :end, :visibility, :participation, :presence => true
  validates :visibility, :inclusion => { :in => ["public", "unlisted", "invite_only"] }
  validates :participation, :inclusion => { :in => ["public", "invite_only"] }
  validate :starting_and_ending_time_must_make_sense

  scope :invited_but_not_participated_by, ->(user) do
    where(:id => user.invited_contests).where.not(:id => user.participated_contests)
  end
  scope :upcoming, -> { where(arel_table[:start].gt(Time.now)) }
  scope :ongoing,  -> do
    where(arel_table[:end].gt(Time.now).
      and(arel_table[:start].lt(Time.now)))
  end
  scope :ended, -> { where(arel_table[:end].lt(Time.now)) }
  scope :not_ended, -> { where(arel_table[:end].gt(Time.now)) }
  scope :participated_by, ->(user) { where(:id => user.participated_contests) }

  has_one :permalink, :as => :linkable, :dependent => :destroy
  has_many :announcements, :validate => false
  has_and_belongs_to_many :problems, :validate => false
  belongs_to :creator, :class_name => "User", :validate => false
  has_and_belongs_to_many :invited_users, :class_name => "User", :validate => false
  has_and_belongs_to_many :participants, :class_name => "User", :join_table => "contests_participants", :validate => false
  has_many :contest_results

  accepts_nested_attributes_for :permalink, :update_only => true, :reject_if => :all_blank, :allow_destroy => true

  def starting_and_ending_time_must_make_sense
    if self.start && self.end && self.start > self.end
      errors.add(:start, "can't happen after end")
    end
  end

  def self.possible_visibilities
    {
      :public => "Public",
      :unlisted => "Unlisted",
      :invite_only => "Invite only"
    }
  end

  def self.possible_participations
    {
      :public => "Public",
      :invite_only => "Invite only"
    }
  end

  def listed_to?(user)
    if creator == user
      true
    elsif visibility == "public"
      true
    elsif visibility == "unlisted"
      invited_users.include?(user)
    elsif visibility == "invite_only"
      invited_users.include?(user)
    else
      true
    end
  end

  def visible_to?(user)
    if creator == user
      true
    elsif visibility == "public"
      true
    elsif visibility == "unlisted"
      true
    elsif visibility == "invite_only"
      invited_users.include?(user)
    else
      true
    end
  end

  def can_access_problems_list?(user)
    (user && user.admin?) || (status != :not_started)
  end

  def can_participate_by?(user)
    if participation == "public"
      true
    elsif participation == "invite_only"
      invited_users.include?(user)
    else
      false
    end
  end

  def status
    if Time.now < self.start
      :not_started
    elsif valid? && Time.now.between?(self.start, self.end)
      :in_progress
    elsif Time.now > self.end
      :ended
    end
  end

  def formatted_status
    {
      :not_started => "Not started",
      :in_progress => "In progress",
      :ended       => "Ended"
    }[status]
  end

  def num_problems_solved_by(user)
    problems.to_a.count do |problem|
      problem.solved_between_by?(Time.at(0), self.end, user)
    end
  end

  def total_points_for(user)
    problems.inject(0) do |sum, problem|
      sum + problem.points_for_between(user, Time.at(0), self.end)
    end
  end

  def leaderboard
    contest_results.order(:total_score => :desc).map do |result|
      {
        :user        => result.user,
        :problems    => Hash[result.scores.map do |problem_id, tasks|
                          [problem_id.to_i, Task.find(tasks.select { |_, v| v }.keys).inject(0) { |s, t| s + t.point }]
                        end],
        :total_score => result.total_score
      }
    end
  end
end
