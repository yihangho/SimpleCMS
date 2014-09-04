module Notifier
  module PushBullet
    def self.notify(message, title="SimpleCMS", url=nil)
      return unless ENV['PUSHBULLET_ACCESS_TOKEN']

      access_token = ENV['PUSHBULLET_ACCESS_TOKEN']

      params = {
        :title => title,
        :body  => message
      }

      if url
        params[:type] = "link"
        params[:url]  = url
      else
        params[:type] = "note"
      end

      RestClient.post("https://#{access_token}@api.pushbullet.com/v2/pushes", params)
    end
  end
end
