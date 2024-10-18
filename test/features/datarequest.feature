@datarequest
@OpenData
@multi_plugin
Feature: Data Request

    @unauthenticated
    Scenario: When visiting the datarequests page as a non-logged in user, the 'Add data request' button is not visible
        Given "Unauthenticated" as the persona
        When I go to the data requests page
        Then the browser's URL should contain "/datarequest"
        And I should not see an element with xpath "//a[contains(translate(string(), 'DR', 'dr'), 'Add data request')]"

    @unauthenticated
    Scenario: Organisation data requests are accessible via the organisation page
        Given "Unauthenticated" as the persona
        When I go to organisation page
        And I click the link with text that contains "Test Organisation"
        And I press the element with xpath "//ul[contains(@class, 'nav-tabs')]//a[contains(string(), 'Data Requests')]"
        Then the browser's URL should contain "/organization/datarequest"
        And I should see an element with xpath "//input[contains(@aria-label, 'Search Data Requests')]"
        And I should see an element with xpath "//ol[contains(@class, 'breadcrumb')]//a[contains(@href, '/organization')]"
        And I should see an element with xpath "//ol[contains(@class, 'breadcrumb')]//a[contains(@href, '/organization/') and contains(string(), 'Test Organisation')]"

    Scenario: User data request page is accessible via the user profile
        Given "CKANUser" as the persona
        When I log in
        And I go to the "ckan_user" profile page
        And I press the element with xpath "//ul[contains(@class, 'nav-tabs')]//a[contains(string(), 'Data Requests')]"
        Then the browser's URL should contain "/user/datarequest"
        And I should see an element with xpath "//input[contains(@aria-label, 'Search Data Requests')]"
        And I should see an element with xpath "//ol[contains(@class, 'breadcrumb')]//a[contains(@href, '/user') and contains(string(), 'Users')]"
        And I should see an element with xpath "//ol[contains(@class, 'breadcrumb')]//a[contains(@href, '/user/') and contains(string(), 'CKAN User')]"

    Scenario: User data request page is not accessible to other non-admins
        Given "CKANUser" as the persona
        When I log in
        And I go to "/user/datarequest/admin"
        Then I should see an element with xpath "//*[contains(string(), 'Not authorised to see this page')]"

    @unauthenticated
    Scenario: User's data request page is not accessible anonymously
        Given "Unauthenticated" as the persona
        When I go to "/user/datarequest/admin"
        Then I should see an element with xpath "//*[contains(string(), 'Not authorised to see this page')]"

    Scenario: Data requests submitted without a description will produce an error message
        Given "SysAdmin" as the persona
        When I log in
        And I go to the data requests page
        And I press "Add data request"
        And I fill in "title" with "Test data request"
        And I press the element with xpath "//button[contains(@class, 'btn-primary')]"
        Then I should see an element with the css selector "div.error-explanation.alert.alert-error" within 2 seconds
        And I should see "The form contains invalid entries" within 1 seconds
        And I should see an element with the css selector "span.error-block" within 1 seconds
        And I should see "Description cannot be empty" within 1 seconds

    Scenario: When a logged-in user submits a Data Request containing profanity they should receive an error message and the request will not be created
        Given "TestOrgEditor" as the persona
        When I log in
        And I go to the data requests page
        And I press "Add data request"
        And I fill in title with random text
        And I fill in "description" with "He had sheep, and oxen, and he asses, and menservants, and maidservants, and she asses, and camels."
        And I press the element with xpath "//button[contains(@class, 'btn-primary') and contains(string(), 'Create data request')]"
        Then I should see "Blocked due to profanity" within 5 seconds

    Scenario: Data request creator and Sysadmin can see a 'Close' button on the data request detail page for opened data requests
        Given "SysAdmin" as the persona
        When I log in
        And I go to the data requests page containing "Test Request"
        And I press "Test Request"
        Then I should see an element with xpath "//a[contains(string(), 'Close')]"

    Scenario Outline: Non admin users cannot see a 'Close' button on the data request detail page for opened data requests
        Given "<User>" as the persona
        When I log in
        And I go to the data requests page containing "Test Request"
        And I press "Test Request"
        Then I should not see an element with xpath "//a[contains(string(), 'Close')]"

        Examples: Users
        | User                  |
        | CKANUser              |
        | DataRequestOrgEditor  |
        | TestOrgEditor         |
        | TestOrgMember         |

    Scenario: Creating a new data request will show the data request afterward
        Given "TestOrgEditor" as the persona
        When I log in
        And I create a datarequest
        Then I should see an element with xpath "//i[contains(@class, 'icon-unlock')]"
        And I should see an element with xpath "//a[contains(string(), 'Close')]"

    Scenario: Closing a data request will show the data request afterward
        Given "DataRequestOrgAdmin" as the persona
        When I log in
        And I create a datarequest
        And I press the element with xpath "//a[contains(string(), 'Close')]"
        And I select "Requestor initiated closure" from "close_circumstance"
        And I press the element with xpath "//button[contains(@class, 'btn-danger') and contains(string(), 'Close data request')]"
        Then I should see an element with xpath "//i[contains(@class, 'icon-lock')]"
        And I should not see an element with xpath "//a[contains(string(), 'Close')]"

    Scenario: Delete all data requests for a user
        # Use a different profile so we don't delete any other test requests
        Given "TestOrgAdmin" as the persona
        When I log in
        And I create a datarequest
        And I create a datarequest
        And I create a datarequest
        And I go to the "test_org_admin" profile page
        And I take a debugging screenshot
        And I press the element with xpath "//ul[contains(@class, 'nav-tabs')]//a[contains(string(), 'Data Requests')]"
        And I take a debugging screenshot
        Then I should see an element with xpath "//a[@title='Delete' and contains(@class, 'btn-danger')]"
        And I should not see an element with xpath "//a[contains(@class, 'btn-danger-serious')]"

        Given "SysAdmin" as the persona
        When I log out
        And I log in
        And I go to the "test_org_admin" profile page
        And I take a debugging screenshot
        And I press the element with xpath "//ul[contains(@class, 'nav-tabs')]//a[contains(string(), 'Data Requests')]"
        And I take a debugging screenshot
        Then I should see an element with xpath "//a[@title='Delete' and contains(@class, 'btn-danger')]"
        And I should see an element with xpath "//a[contains(@title, 'Delete all') and contains(@class, 'btn-danger-serious')]"

        When I press the element with xpath "//a[contains(@title, 'Delete all') and contains(@class, 'btn-danger-serious')][1]"
        And I take a debugging screenshot
        And I confirm the dialog containing "Are you sure you want to" if present
        And I take a debugging screenshot
        Then I should see an element with xpath "//div[contains(@class, 'alert') and contains(string(), 'Deleted') and contains(string(), 'data request(s)')]"

        When I go to the "test_org_admin" profile page
        And I press the element with xpath "//ul[contains(@class, 'nav-tabs')]//a[contains(string(), 'Data Requests')]"
        Then I should see "No data requests found"

    Scenario: An unprivileged user who tries to create multiple data requests close together should see an error
        Given "CKANUser" as the persona
        When I log in
        And I create a datarequest
        And I go to the data requests page
        And I press "Add data request"
        And I fill in title with random text
        And I fill in "description" with "Test throttling"
        And I press the element with xpath "//button[contains(@class, 'btn-primary')]"
        Then I should see "Too many requests submitted, please wait"

    Scenario: As an org admin I can re-open a closed data request
        Given "DataRequestOrgAdmin" as the persona
        When I log in
        And I create a datarequest
        And I press the element with xpath "//a[contains(string(), 'Close')]"
        And I select "Requestor initiated closure" from "close_circumstance"
        And I press the element with xpath "//button[contains(@class, 'btn-danger') and contains(string(), 'Close data request')]"
        Then I should see an element with xpath "//a[contains(string(), 'Re-open')]"
        When I press the element with xpath "//a[contains(string(), 'Re-open')]"
        Then I should see an element with xpath "//i[contains(@class, 'icon-unlock')]"
        And I should see an element with xpath "//a[contains(string(), 'Close')]"
