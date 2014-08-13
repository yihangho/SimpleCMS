module LocalAttachmentManager
  require 'fileutils'
  TASK_INPUT_DIRECTORY = ENV["SIMPLECMS_INPUT"] || "#{ENV["HOME"]}/.simplecms/input";
  TASK_OUTPUT_DIRECTORY = ENV["SIMPLECMS_OUTPUT"] || "#{ENV["HOME"]}/.simplecms/output";
  SUBMISSION_DIRECTORY = ENV["SIMPLECMS_SUBMISSION"] || "#{ENV["HOME"]}/.simplecms/submission";

  def upload arg
    # Archie the stuff first
    archive_contents()
    contents_to_be_uploaded = arg.to_s
    pathname = AttachmentParser.generate_file contents_to_be_uploaded , self.attachmentable_type , self.id
    FileUtils.mv(pathname , directory)
    self.file_name = File.basename(pathname)
  end

  def contents
    self.file.read
  end

  def file
    File.open "#{self.directory}/#{self.file_name}" , "r+"
  end

  def directory
    return @directory unless @directory.nil?

    case self.attachmentable_type
    when "task-input"
      @directory = TASK_INPUT_DIRECTORY
    when "task-output"
      @directory = TASK_OUTPUT_DIRECTORY
    when "submission"
      @directory = SUBMISSION_DIRECTORY
    end
    FileUtils::mkdir_p @directory unless File.directory? @directory

    @directory
  end
end
