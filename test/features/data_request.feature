@config
@OpenData
Feature: Data Request

    Scenario Outline: As a logged in user I can request new data
       Given "User" as the persona
        When I log in
        And I visit "datarequest/new"
        And I fill in title with random text
        And I fill in "description" with "Data Request description"
        And I press "Create data request"
        Then I should see an element with xpath "//h1[contains(@class, 'page-heading') and contains(text(), 'Test Title ')]"
        And I should see an element with xpath "//div[contains(@class, 'notes') and contains(text(), 'Data Request description')]"
