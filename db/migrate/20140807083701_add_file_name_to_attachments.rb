class AddFileNameToAttachments < ActiveRecord::Migration
  def change
    add_column :attachments , :file_name , :string
  end
end
