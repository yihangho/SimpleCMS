class AddActiveToAttachmentsTable < ActiveRecord::Migration
  def change
    add_column :attachments , :active , :boolean , :default => true
  end
end
