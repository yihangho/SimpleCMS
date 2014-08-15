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

Given(/^I am a registered user$/) do
  @user = User.create(:username => "test", :email => "test@example.com", :password => "12345", :password_confirmation => "12345")
end

Given(/^I am a signed\-in user$/) do
  step "I am a registered user"
  step %Q(I am visiting "/signin")
  step "I submit the signin form with my username and password"
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

When(/^I submit the signin form with my (.*?) and password$/) do |identifier|
  fill_in 'Username/Email', :with => @user.send(identifier.to_sym)
  fill_in 'Password', :with => @user.password
  click_button 'Sign In'
end

When(/^I submit the signin form with incorrect (.*?)$/) do |field|
  fill_in 'Username/Email', :with => @user.username
  fill_in 'Password', :with => @user.password
  fill_in field.capitalize, :with => @user.send(field.to_sym) + "bla"
  click_button 'Sign In'
end

Then(/^I should be on "(.*?)"$/) do |path|
  expect(current_path).to eq path
end

Then(/^I should see "(.*?)"$/) do |content|
  expect(page).to have_content(content)
end

Then(/^I should be on my profile page$/) do
  step %(I should be on "#{user_path(@user)}")
end
