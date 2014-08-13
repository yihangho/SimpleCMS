module AttachmentParser
  extend ActiveSupport::Concern
  
  require 'fileutils'

  def self.generate_file contents , file_type , provided_id
    contents.tr! "\r" , ""
    extension = file_type.to_sym == :'task-input' ? "in" : "out"
    directory = "/tmp/simple-cms/#{file_type}"
    FileUtils::mkdir_p directory unless File.directory? directory
    pathname = "#{directory}/#{file_type}-#{(Time.now.to_f * 1000).to_i}-#{provided_id}.#{extension}"
    File.open(pathname , "w") { |f| f.write(contents) }
    pathname
  end
end
