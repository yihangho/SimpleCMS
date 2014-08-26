class AddCodeToSubmissions < ActiveRecord::Migration
  def change
    add_column :submissions, :code, :text, :default => ""
    remove_column :submissions, :code_link, :string
  end
end
