class AddDefaultAdminUser < ActiveRecord::Migration
  ADMIN_ATTRIBUTES = {
    :username               => "admin",
    :school                 => "admin",
    :email                  => "admin@admin.com",
    :password               => "password",
    :password_confirmation  => "password",
    :admin                  => true
  }

  def up
    User.create(ADMIN_ATTRIBUTES)
  end

  def down
    User.where(ADMIN_ATTRIBUTES.slice(
      :username, :email, :school, :admin)).destroy_all
  end
end
