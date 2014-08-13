class Attachment < ActiveRecord::Base
  belongs_to :attachmentable
  attr_accessor :contents_to_be_uploaded
  validate :attachmentable_type , :inclusion => { :in => ["task-input" , "task-output" , "submission"] }
  has_many :archives , class_name: "Attachment" , :foreign_key => "parent_id"
  belongs_to :parent , class_name: "Attachment"
  # Include the type of module depensing on the type of communication wanted
  # No matter what module is used, please do add two vital methods:
  # upload(args) => Upload contents to that attachment
  # contents => Obtaint the content of the downloaded file as a string

  # before_save do
  #   if self.active && self.id
  #     archives.build :file_name => file_name , :active => false , :attachmentable_id => attachmentable_id , :attachmentable_type => attachmentable_type 
  #   end
  # end

  def archive_contents
    if self.active && self.id
      archives.build :file_name => file_name , :active => false , :attachmentable_id => attachmentable_id , :attachmentable_type => attachmentable_type 
    end
  end

  case ENV["SIMPLECMS_STORAGE_TYPE"]
  when "AWS"
    include AwsAttachmentCommunication
  when "local"
    include LocalAttachmentManager
  else
    include LocalAttachmentManager
  end
end
