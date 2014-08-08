class Attachment < ActiveRecord::Base
  belongs_to :attachmentable
  attr_accessor :contents_to_be_uploaded
  validate :attachmentable_type , :inclusion => { :in => ["task-input" , "task-output" , "submission"] }

  before_save do
    self.contents_to_be_uploaded ||= ""
    self.contents_to_be_uploaded = self.contents_to_be_uploaded.to_s
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

    directory_variable_name = "#{self.attachmentable_type.to_s.gsub "-" , '_'}_directory".to_sym
    aws_directory_name = "simple-cms-#{self.attachmentable_type}".to_sym

    return @directory = self.class.send(directory_variable_name) unless self.class.send(directory_variable_name).nil?

    self.class.aws_connection.directories.each do |dir|
      return @directory = self.class.send("#{directory_variable_name}=".to_sym , dir) if dir.key.to_sym == aws_directory_name
    end

    @directory = self.class.aws_connection.directories.create({
      :key => aws_directory_name,
      :public => false
    })

    self.class.send("#{directory_variable_name}=".to_sym , @directory)
  end

  class << self
    attr_accessor :task_input_directory , :task_output_directory , :submission_directory

    def aws_connection
      @connection ||= Fog::Storage.new({
        :provider                 => 'AWS',
        :aws_access_key_id        => ENV['AWS_ID'],
        :aws_secret_access_key    => ENV['AWS_SECRET_KEY']
      })
    end
  end
end