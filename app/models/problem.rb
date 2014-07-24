class Problem < ActiveRecord::Base
  validates :title, :statement, :visibility, :presence => true
  validates :visibility, :inclusion => { :in => ["public", "unlisted", "contest_only"] }
  belongs_to :setter, :class_name => "User", :validate => false
  has_many :tasks, :dependent => :destroy, :validate => false
  has_and_belongs_to_many :contests, :validate => false
  has_and_belongs_to_many :solvers, :class_name => "User", :join_table => "solved_problems", :validate => false

  def self.possible_visibilities
    {
      :public => "Public",
      :unlisted => "Unlisted",
      :contest_only => "Contest only"
    }
  end

  def listed_to?(user)
    if setter == user
      true
    elsif visibility == "public"
      true
    elsif visibility == "unlisted"
      false
    elsif visibility == "contest_only"
      false
    else
      true
    end
  end

  def visible_to?(user)
    if setter == user
      true
    elsif visibility == "public"
      true
    elsif visibility == "unlisted"
      true
    elsif visibility == "contest_only"
      user && contests.any? { |contest| contest.participants.include?(user) && contest.status != :not_started }
    else
      true
    end
  end

  def solved_by?(user)
    solvers.include?(user)
  end
end
