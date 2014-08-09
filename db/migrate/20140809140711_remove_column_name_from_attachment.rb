class RemoveColumnNameFromAttachment < ActiveRecord::Migration
  def change
    remove_column :attachments , :name
  end
end
