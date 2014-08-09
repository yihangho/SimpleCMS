module AwsAttachmentCommunication
  attr_accessor :contents_to_be_uploaded , :pathname

  # The core two functions to be included
  def upload args
    contents_to_be_uploaded = args.to_s
    @pathname = AttachmentParser.generate_file contents_to_be_uploaded , self.attachmentable_type , self.id
    create_at_upstream
    self.file_name = File.basename(@pathname)
  end

  def contents #returns nil if file doesn't exist, empty string if file is empty
    self.file ? self.file.body : nil
  end
  # End of core functions

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
    x = self.attachmentable_type
    if x == "task-input"
      @directory = AwsAttachmentCommunication.task_input_directory
    elsif x == "task-output"
      @directory = AwsAttachmentCommunication.task_output_directory
    elsif x == "submission"
      @directory = AwsAttachmentCommunication.submission_directory
    end
  end

  class << self
    attr_reader :task_input_directory , :task_output_directory , :submission_directory , :aws_connection

    def establish_aws_connection
      @aws_connection = Fog::Storage.new({
        :provider                 => 'AWS',
        :aws_access_key_id        => ENV['AWS_ID'],
        :aws_secret_access_key    => ENV['AWS_SECRET_KEY'],
        :region                   => ENV["AWS_REGION"]
      })

      @task_input_directory = aws_connection.directories.get(ENV["SIMPLECMS_INPUT"])
      @task_output_directory = aws_connection.directories.get(ENV["SIMPLECMS_OUTPUT"])
      @submission_directory = aws_connection.directories.get(ENV["SIMPLECMS_SUBMISSION"])
    end
  end

  AwsAttachmentCommunication.establish_aws_connection
end