class Contest < ActiveRecord::Base
  validates :title, :start, :end, :presence => true
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

  def listed_to?(user)
    if visibility == "public"
      true
    elsif visibility == "unlisted"
      false
    elsif visibility == "invite_only"
      invited_users.include?(user)
    else
      true
    end
  end

  def status
    if Time.now < self.start
      :not_started
    elsif Time.now >= self.start && Time.now <= self.end
      :in_progress
    elsif Time.now > self.end
      :ended
    end
  end
end
