class Session < ActiveRecord::Base
  validates :remember_token, :presence => true
  belongs_to :user, :validate => false

  def self.new_remember_token
    SecureRandom.uuid
  end

  def self.hash(token)
    Digest::SHA1.hexdigest(token.to_s)
  end

  def self.get_user(remember_token)
    session = find_by(:remember_token => hash(remember_token))
    if session
      session.user
    else
      nil
    end
  end

  def setup_new_remember_token
    remember_token = self.class.new_remember_token

    self.remember_token = self.class.hash(remember_token)

    remember_token
  end
end
