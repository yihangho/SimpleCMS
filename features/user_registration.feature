Feature: User registration
  In order to start using SimpleCMS
  As a new user
  I want to create a new account

  Scenario: Creating an account
    Given I am visiting "/users/new"
    When  I submit the user registration form with valid information
    Then  I should be on "/problems"

  Scenario: Creating an account when username is taken
    Given I am visiting "/users/new"
    And   An account with username set to "test" had been created
    When  I submit the user registration form with valid information
    Then  I should see "Username has already been taken"

  Scenario: Creating an account when username is taken
    Given I am visiting "/users/new"
    And   An account with email set to "test@example.com" had been created
    When  I submit the user registration form with valid information
    Then  I should see "Email has already been taken"

  Scenario: Password does not match password confirmation
    Given I am visiting "/users/new"
    When  I submit the user registration form with unmatching password and password confirmation
    Then  I should see "Password confirmation doesn't match Password"

  Scenario: Signed-in user trying to access the user registration page
    Given I am a signed-in user
    When  I am visiting "/users/new"
    Then  I should be on my profile page
