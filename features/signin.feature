Feature: Signin
  In order to perform some restricted actions
  As a registered user
  I want signin using my account

  Scenario: Using correct username/password combo
    Given I am a registered user
    And   I am visiting "/signin"
    When  I submit the signin form with my username and password
    Then  I should be on my profile page

  Scenario: Using correct email/password combo
    Given I am a registered user
    And   I am visiting "/signin"
    When  I submit the signin form with my email and password
    Then  I should be on my profile page

  Scenario: Using incorrect username
    Given I am a registered user
    And   I am visiting "/signin"
    When  I submit the signin form with incorrect username
    Then  I should see "Wrong email/username and/or password."

  Scenario: Using incorrect email
    Given I am a registered user
    And   I am visiting "/signin"
    When  I submit the signin form with incorrect email
    Then  I should see "Wrong email/username and/or password."

  Scenario: Using incorrect password
    Given I am a registered user
    And   I am visiting "/signin"
    When  I submit the signin form with incorrect password
    Then  I should see "Wrong email/username and/or password."

  Scenario: Signed-in user trying to access sign in page
    Given I am a signed-in user
    When  I am visiting "/signin"
    Then  I should be on my profile page
