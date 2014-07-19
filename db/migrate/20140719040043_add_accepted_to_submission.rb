class AddAcceptedToSubmission < ActiveRecord::Migration
  def change
    add_column :submissions, :accepted, :boolean
  end
end
