Feature: Ordered tasks

  Scenario: Visiting a problem page
    Given I am a signed-in user
    And   A non-contest-only problem with these tasks:
      |  input | output | point | order |
      | input1 |      1 |    30 |     3 |
      | input2 |      2 |    70 |     1 |
      | input3 |      3 |   100 |     2 |
    When  I visit the problem page
    Then  I should see the following, in that order:
      | input2 |
      | input3 |
      | input1 |
