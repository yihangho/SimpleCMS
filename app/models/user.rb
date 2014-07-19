class User < ActiveRecord::Base
  validates :email, :format => { :with => /\A.+?@.+?\..+\z/ }
  has_secure_password
  has_many :submissions

  def self.new_remember_token
    SecureRandom.uuid
  end

  def self.hash(token)
    Digest::SHA1.hexdigest(token.to_s)
  end
end
