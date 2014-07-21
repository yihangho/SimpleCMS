class Problem < ActiveRecord::Base
  validates :title, :statement, :presence => true
  belongs_to :setter, :class_name => "User"
  has_many :tasks, :dependent => :destroy
  has_and_belongs_to_many :contests
  has_and_belongs_to_many :solvers, :class_name => "User", :join_table => "solved_problems"
end
