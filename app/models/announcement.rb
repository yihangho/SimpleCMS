class Announcement < ActiveRecord::Base
  belongs_to :sender, :class_name => "User", :foreign_key => "sender_id", :validate => false
  belongs_to :contest, :validate => false
end
