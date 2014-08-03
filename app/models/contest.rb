class Contest < ActiveRecord::Base
  include Linkable

  validates :title, :start, :end, :visibility, :participation, :presence => true
  validates :visibility, :inclusion => { :in => ["public", "unlisted", "invite_only"] }
  validates :participation, :inclusion => { :in => ["public", "invite_only"] }
  validate :starting_and_ending_time_must_make_sense

  scope :invited_but_not_participated_by, ->(user) do
    where(:id => user.invited_contests).where.not(:id => user.participated_contests)
  end
  scope :upcoming, -> { where("\"contests\".\"start\" > ?", Time.now) }
  scope :ongoing,  -> do
    where("\"contests\".\"end\" > ?", Time.now).
    where("\"contests\".\"start\" < ?", Time.now)
  end

  has_one :permalink, :as => :linkable, :dependent => :destroy
  has_many :announcements, :validate => false
  has_and_belongs_to_many :problems, :validate => false
  belongs_to :creator, :class_name => "User", :validate => false
  has_and_belongs_to_many :invited_users, :class_name => "User", :validate => false
  has_and_belongs_to_many :participants, :class_name => "User", :join_table => "contests_participants", :validate => false

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

  def leaderboard
    participants.collect do |user|
      {
        :num_solved => num_problems_solved_by(user),
        :user       => user,
        :problems   => problems.collect do |problem|
                         [problem.id, problem.solved_between_by?(Time.at(0), self.end, user)]
                       end.to_h
      }
    end.sort do |row1, row2|
      row1[:num_solved] <=> row2[:num_solved]
    end.reverse
  end
end
