@smoke @login
Feature: Login

    Scenario: Smoke test to ensure Login step works
        Given "Admin" as the persona
        When I log in
        Then I take a screenshot
