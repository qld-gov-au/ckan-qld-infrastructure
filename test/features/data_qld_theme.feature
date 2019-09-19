@data-qld-theme
Feature: Data QLD Theme

       Scenario: Lato font is implemented on homepage
              When I go to homepage
              Then I should see an element with xpath "//link[contains(@href,'https://fonts.googleapis.com/css?family=Lato')]"

       Scenario: Organisation is in fact spelled Organisation (as opposed to Organization) 
              When I go to organisation page
              Then I should not see "Organization"

       Scenario: Explore button does not exist on dataset detail page
              When I go to dataset page
              And I click the link with text that contains "A Wonderful Story"
              Then I should not see "Explore"

       Scenario: Explore button does not exist on dataset detail page
              When I go to organisation page
              Then I should see "Organisations are Queensland Government departments, other agencies or legislative entities responsible for publishing open data on this portal."

      Scenario: Register user password must be 10 characters or longer
              When I go to register page
              And I fill in "name" with "name"
              And I fill in "fullname" with "fullname"
              And I fill in "email" with "email@test.com"
              And I fill in "password1" with "pass"
              And I fill in "password2" with "pass"
              And I press "Create Account"
              Then I should see "Password: Your password must be 10 characters or longer"

       Scenario: Register user password must contain at least one number, lowercase letter, capital letter, and symbol
              When I go to register page
              And I fill in "name" with "name"
              And I fill in "fullname" with "fullname"
              And I fill in "email" with "email@test.com"
              And I fill in "password1" with "password1234"
              And I fill in "password2" with "password1234"
              And I press "Create Account"
              Then I should see "Password: Must contain at least one number, lowercase letter, capital letter, and symbol"
