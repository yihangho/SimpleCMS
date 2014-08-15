Feature: Solving problems

  Scenario: Submitting answers for a task
    Given I am a signed-in user
    And   A non-contest-only problem with these tasks:
      | input | output | point |
      |     1 |      1 |    30 |
      |     2 |      2 |    70 |
    When  I submit the incorrect answer for task 1
    Then  I should see "Your last submission was incorrect."
    And   I should see "(0 / 100)"
    And   I should not see "Solved"
    When  I submit the correct answer for task 1
    Then  I should see "Your last submission was correct."
    And   I should see "(30 / 100)"
    When  I submit the incorrect answer for task 1
    Then  I should see "Your last submission was incorrect."
    But   I should see "(30 / 100)"
    When  I submit the correct answer for task 2
    Then  I should see "Your last submission was correct."
    And   I should see "(100 / 100)"
