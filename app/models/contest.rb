class Contest < ActiveRecord::Base
  validates :title, :start, :end, :visibility, :participation, :presence => true
  validates :visibility, :inclusion => { :in => ["public", "unlisted", "invite_only"] }
  validates :participation, :inclusion => { :in => ["public", "invite_only"] }
  validate :starting_and_ending_time_must_make_sense

  has_and_belongs_to_many :problems
  belongs_to :creator, :class_name => "User"
  has_and_belongs_to_many :invited_users, :class_name => "User"
  has_and_belongs_to_many :participants, :class_name => "User", :join_table => "contests_participants"

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
      false
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
end
