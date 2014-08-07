class Attachment < ActiveRecord::Base
  belongs_to :attachmentable
  attr_accessor :contents_to_be_uploaded , :previous_record
  validate :attachmentable_type , :inclusion => { :in => ["task-input" , "task-output" , "submission"] }

  before_save do
    self.contents_to_be_uploaded ||= ""
    @pathname = AttachmentParser.generate_file self.contents_to_be_uploaded , self.attachmentable_type , self.attachmentable_id
    self.create_at_upstream
    self.file_name = File.basename(@pathname)
  end

  def contents #returns nil if file doesn't exist, empty string if file is empty
    self.file ? self.file.body : nil
  end

  def create_at_upstream
    self.directory.files.new({
      :key => File.basename(@pathname),
      :body => File.open(@pathname),
      :public => false
    }).save
  end

  def file
    return @file unless @file.nil?
    return nil unless directory.files.head self.file_name
    directory.files.get self.file_name
  end

  def directory
    return @directory unless @directory.nil?

    if self.attachmentable_type == "task-input"
      directory_name = "simple-cms-input"
    elsif self.attachmentable_type == "task-output"
      directory_name = "smple-cms-output"
    else
      directory_name = "simple-cms-submission"
    end

    self.connection.directories.each do |dir|
      return @directory = dir if dir == directory_name
    end

    @directory = self.connection.directories.create({
      :key => directory_name,
      :public => false
    })
  end

  def connection
    @connection ||= Fog::Storage.new({
      :provider                 => 'AWS',
      :aws_access_key_id        => ENV['AWS_ID'],
      :aws_secret_access_key    => ENV['AWS_SECRET_KEY']
    })
  end
end