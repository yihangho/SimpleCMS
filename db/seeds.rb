# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

password = SecureRandom.hex(5)
credentials = {
  :username               => "admin",
  :school                 => "admin",
  :email                  => "admin@admin.com",
  :password               => password,
  :password_confirmation  => password,
  :admin                  => true
}

puts "Creating admin user ..."
User.create(credentials)
puts "username: #{credentials[:admin]}"
puts "email: #{credentials[:email]}"
puts "password: #{credentials[:password]}"
