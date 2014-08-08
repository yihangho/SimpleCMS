class User < ActiveRecord::Base
  validates :username, :presence => true, :uniqueness => { :case_sensitive => false }, :format => { :with => /\A\w*\z/ }
  validates :email, :format => { :with => /\A.+?@.+?\..+\z/ }, :uniqueness => { :case_sensitive => false }
  has_secure_password
  has_many :sessions, :validate => false
  has_many :submissions, :validate => false
  has_many :set_problems, :class_name => "Problem", :foreign_key => "setter_id", :validate => false
  has_many :created_contests, :class_name => "Contest", :foreign_key => "creator_id", :validate => false
  has_many :announcements, :foreign_key => "sender_id", :validate => false
  has_and_belongs_to_many :invited_contests, :class_name => "Contest", :validate => false
  has_and_belongs_to_many :participated_contests, :class_name => "Contest", :join_table => "contests_participants", :validate => false
  has_and_belongs_to_many :solved_problems, :class_name => "Problem", :join_table => "solved_problems", :validate => false
  has_and_belongs_to_many :solved_tasks, :class_name => "Task", :join_table => "solved_tasks", :validate => false
end
