class Problem < ActiveRecord::Base
  has_many :tasks, :dependent => :destroy
  has_and_belongs_to_many :contests
end
