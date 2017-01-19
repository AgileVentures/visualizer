Feature: As a user
  In order to have my report delivered to my inbox
  I would like to be able to submit my email address.

  Scenario: I send an email
    Given I am on the "Get Data" page
    When I fill in "email-input" with "example@example.com"
    And I click on "Send"
    Then "example@example.com" should receive an email