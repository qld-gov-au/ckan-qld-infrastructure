Feature: Navigation

    Scenario: Check for the presence of the 'Copyright' link in footer when visiting as a non-logged in user
        When I go to homepage
        Then I should see an element with xpath "//footer/div/ul/li/a[contains(string(), "Copyright")]"

    Scenario: Check for the presence of the 'Disclaimer' link in footer when visiting as a non-logged in user
        When I go to homepage
        Then I should see an element with xpath "//footer/div/ul/li/a[contains(string(), "Disclaimer")]"

