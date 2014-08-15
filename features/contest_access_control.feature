Feature: Contest access control

  Scenario: Invited user accessing invite-only contest
    Given an invite-only contest
    And   I am a signed-in user
    And   I am invited to the contest
    And   I am visiting the contest page
    Then  I should see the link "Participate"

  Scenario: Uninvited user accessing invite-only contest
    Given an invite-only contest
    And   I am a signed-in user
    And   I am visiting the contest page
    Then  I should not see the link "Participate"
