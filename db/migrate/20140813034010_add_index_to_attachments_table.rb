class AddIndexToAttachmentsTable < ActiveRecord::Migration
  def change
    add_index :attachments , :parent_id
    add_index :attachments , :attachmentable_id
    add_index :attachments , :attachmentable_type
  end
end
