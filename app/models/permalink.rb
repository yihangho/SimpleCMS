class Permalink < ActiveRecord::Base
  validates :url, :presence => true, :uniqueness => { :case_sensitive => false }
  belongs_to :linkable, :polymorphic => true

  def to_s
    url
  end
end
