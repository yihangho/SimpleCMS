class CreateAttachments < ActiveRecord::Migration
  def change
    create_table :attachments do |t|
      t.string :name
      t.references :attachmentable , polymorphic: true
      t.timestamps
    end
  end
end
