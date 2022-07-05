@user_creation
Feature: User creation

    Scenario: SysAdmin create a new user to the site.
        Given "SysAdmin" as the persona
        When I log in
        When I go to "/user/register"
        Then I should see an element with xpath "//input[@name='fullname']"
        And I should see "Displayed name"
        Then I fill in "name" with "publisher_user"
        Then I fill in "fullname" with "gov user"
        And I press the element with xpath "//button[contains(@class, 'btn-primary')]"
        And I wait for 10 seconds
        Then I should not see "The username cannot contain the word 'publisher'. Please enter another username."
        Then I should not see "The displayed name cannot contain certain words such as 'publisher', 'QLD Government' or similar. Please enter another display name."

    Scenario: Non logged-in user register to the site.
        When I go to register page
        Then I should see an element with xpath "//input[@name='fullname']"
        And I should see "Displayed name"
        Then I fill in "name" with "publisher_user"
        Then I fill in "fullname" with "gov user"
        And I press the element with xpath "//button[contains(@class, 'btn-primary')]"
        And I wait for 10 seconds
        Then I should see "The username cannot contain the word 'publisher'. Please enter another username."
        Then I should see "The displayed name cannot contain certain words such as 'publisher', 'QLD Government' or similar. Please enter another display name."
