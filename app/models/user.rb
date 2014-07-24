class User < ActiveRecord::Base
  validates :name, :presence => true
  validates :email, :format => { :with => /\A.+?@.+?\..+\z/ }
  has_secure_password
  has_many :submissions
  has_many :set_problems, :class_name => "Problem", :foreign_key => "setter_id"
  has_many :created_contests, :class_name => "Contest", :foreign_key => "creator_id"
  has_and_belongs_to_many :invited_contests, :class_name => "Contest"
  has_and_belongs_to_many :participated_contests, :class_name => "Contest", :join_table => "contests_participants"
  has_and_belongs_to_many :solved_problems, :class_name => "Problem", :join_table => "solved_problems"
  has_and_belongs_to_many :solved_tasks, :class_name => "Task", :join_table => "solved_tasks"

  def self.new_remember_token
    SecureRandom.uuid
  end

  def self.hash(token)
    Digest::SHA1.hexdigest(token.to_s)
  end
end
