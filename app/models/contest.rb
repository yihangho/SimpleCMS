class Contest < ActiveRecord::Base
  validates :title, :start, :end, :presence => true
  validate :starting_and_ending_time_must_make_sense

  has_and_belongs_to_many :problems
  belongs_to :creator, :class_name => "User"
  has_and_belongs_to_many :invited_users, :class_name => "User"

  def starting_and_ending_time_must_make_sense
    if self.start && self.end && self.start > self.end
      errors.add(:start, "can't happen after end")
    end
  end
end
