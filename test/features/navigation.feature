Feature: Navigation

    @OpenData
    @unauthenticated
    Scenario: Check for the presence of the 'Request data' link in header when visiting as a non-logged in user
        Given "Unauthenticated" as the persona
        When I go to homepage
        # Make the comparison case-insensitive
        Then I should see an element with xpath "//a[contains(translate(., 'RD', 'rd'), "request data")]"

    @OpenData
    Scenario: Check for the presence of the 'Request data' link in header when visiting as a logged in user
        Given "SysAdmin" as the persona
        When I log in
        And I go to homepage
        # Make the comparison case-insensitive
        Then I should see an element with xpath "//a[contains(translate(., 'RD', 'rd'), "request data")]"

    Scenario: Check for the presence of the 'Copyright' link in footer when visiting as a non-logged in user
        Given "Unauthenticated" as the persona
        When I go to homepage
        Then I should see an element with xpath "//footer/div/ul/li/a[contains(string(), "Copyright")]"

    Scenario: Check for the presence of the 'Disclaimer' link in footer when visiting as a non-logged in user
        Given "Unauthenticated" as the persona
        When I go to homepage
        Then I should see an element with xpath "//footer/div/ul/li/a[contains(string(), "Disclaimer")]"
