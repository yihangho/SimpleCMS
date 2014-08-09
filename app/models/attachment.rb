class Attachment < ActiveRecord::Base
  belongs_to :attachmentable
  attr_accessor :contents_to_be_uploaded
  validate :attachmentable_type , :inclusion => { :in => ["task-input" , "task-output" , "submission"] }

  # Include the type of module depensing on the type of communication wanted
  # No matter what module is used, please do add two vital methods:
  # upload(args) => Upload contents to that attachment
  # contents => Obtaint the content of the downloaded file as a string

  case ENV["SIMPLECMS_STORAGE_TYPE"]
  when "AWS"
    include AwsAttachmentCommunication
  when "local"
    include LocalAttachmentManager
  else
    include AwsAttachmentCommunication
  end
end
