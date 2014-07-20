class User < ActiveRecord::Base
  validates :email, :format => { :with => /\A.+?@.+?\..+\z/ }
  has_secure_password
  has_many :submissions
  has_many :set_problems, :class_name => "Problem", :foreign_key => "setter_id"
  has_many :created_contests, :class_name => "Contest", :foreign_key => "creator_id"

  def self.new_remember_token
    SecureRandom.uuid
  end

  def self.hash(token)
    Digest::SHA1.hexdigest(token.to_s)
  end
end
