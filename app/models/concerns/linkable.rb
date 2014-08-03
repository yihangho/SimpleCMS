module Linkable
  extend ActiveSupport::Concern

  # The permalink to link
  # Returns falsy if permalink cannot be set
  def set_permalink(url)
    return true if url.nil? || url.empty?

    if permalink.nil?
      create_permalink(:url => url).valid?
    else
      permalink.url = url
      permalink.save
    end
  end
end
