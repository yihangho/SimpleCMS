class Problem < ActiveRecord::Base
  validates :title, :statement, :presence => true
  has_many :tasks, :dependent => :destroy
  has_and_belongs_to_many :contests
end
