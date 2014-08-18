World(FactoryGirl::Syntax::Methods)

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

Given(/^A non-contest-only problem with these tasks:$/) do |table|
  @problem = create(:problem, :contest_only => false)
  @tasks   = table.hashes.map do |row|
    row[:problem] = @problem
    create(:task, row)
  end
end

Given(/^an? (invite\-only )?contest$/) do |invite_only|
  p invite_only
  @contest = create(:contest, :participation => "invite_only")
end

Given(/^I am invited to the contest$/) do
  @contest.invited_users << @user
end

Given(/^I have participated in the contest$/) do
  @contest.participants << @user
end

Given(/^the contest has not started$/) do
  @contest.update_attributes(:start => 1.day.from_now, :end => 2.days.from_now)
end

Given(/^I am visiting the contest page$/) do
  step %Q(I am visiting "#{contest_path(@contest)}")
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

When(/^I submit the (in|)correct answer for task (\d+)$/) do |incorrect, index|
  incorrect = (incorrect == "in")
  index = index.to_i

  visit problem_path(@problem)
  within page.all('form')[index-1] do
    fill_in "Answer", :with => @tasks[index-1].output + (incorrect ? "bla" : "")
    click_button "Submit"
  end
end

When(/^I visit the problem page$/) do
  step %Q(I am visiting "#{problem_path(@problem)}")
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

Then(/^I should not see "(.*?)"$/) do |content|
  expect(page).not_to have_content(content)
end

Then(/^I should see the link "(.*?)"$/) do |title|
  expect(page).to have_link(title)
end

Then(/^I should not see the link "(.*?)"$/) do |title|
  expect(page).not_to have_link(title)
end

Then(/^I should see the following, in that order:$/) do |snippets|
  snippets = snippets.raw.flatten
  pattern = snippets.collect(&Regexp.method(:quote)).join('.*?')
  pattern = Regexp.compile(pattern)
  page.text.should =~ pattern
end
