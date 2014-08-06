class AddCodeLinkToSubmissions < ActiveRecord::Migration
  def change
    add_column :submissions, :code_link, :string
  end
end
