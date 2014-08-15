Given(/^I am visiting "(.*?)"$/) do |path|
  visit path
end

Given(/^An account with (.*?) set to "(.*?)" had been created$/) do |key, value|
  hash = {
    :username => "another",
    :email => "another@example.com",
    :password => "12345",
    :password_confirmation => "12345"
  }
  hash[key.to_sym] = value
  User.create(hash)
end

When(/^I submit the user registration form with valid information$/) do
  fill_in 'Username', :with => "test"
  fill_in 'Email', :with => "test@example.com"
  fill_in 'Password', :with => "12345"
  fill_in 'Password confirmation', :with => "12345"
  click_button 'Register'
end

When(/^I submit the user registration form with unmatching password and password confirmation$/) do
  fill_in 'Username', :with => "test"
  fill_in 'Email', :with => "test@example.com"
  fill_in 'Password', :with => "12345"
  fill_in 'Password confirmation', :with => "54321"
  click_button 'Register'
end

Then(/^I should be on "(.*?)"$/) do |path|
  expect(current_path).to eq path
end

Then(/^I should see "(.*?)"$/) do |content|
  expect(page).to have_content(content)
end
