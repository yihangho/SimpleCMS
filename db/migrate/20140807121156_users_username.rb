class UsersUsername < ActiveRecord::Migration
  class User < ActiveRecord::Base
  end

  def up
    remove_index  :users, :name # Why the hell did I add index for name?
    rename_column :users, :name, :username
    add_index     :users, :username, :unique => true

    User.reset_column_information
    User.all.each do |user|
      new_username = user.username.gsub(/\W/, "")
      user.update_attribute(:username, new_username)
    end
  end

  def down
    remove_index  :users, :username
    rename_column :users, :username, :name
    add_index     :users, :name
  end
end
