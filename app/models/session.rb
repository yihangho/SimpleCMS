class Session < ActiveRecord::Base
  belongs_to :user, :validate => false
end
