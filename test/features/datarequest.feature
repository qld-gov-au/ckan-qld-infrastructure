@OpenData
@datarequest
Feature: Data Request

    @unauthenticated
    Scenario: Data Requests are accessible via the /datarequest URL
        Given "Unauthenticated" as the persona
        When I go to the data requests page
        Then the browser's URL should contain "/datarequest"

    @unauthenticated
    Scenario: When visiting the datarequests page as a non-logged in user, the 'Add data request' button is not visible
        Given "Unauthenticated" as the persona
        When I go to the data requests page
        Then I should not see an element with xpath "//a[contains(string(), 'Add data request', 'i')]"

    Scenario: Data requests submitted without a description will produce an error message
        Given "SysAdmin" as the persona
        When I log in and go to the data requests page
        And I press the element with xpath "//a[contains(@class, 'btn-primary')]"
        And I fill in "title" with "Test data request"
        And I press the element with xpath "//button[contains(@class, 'btn-primary')]"
        Then I should see an element with the css selector "div.error-explanation.alert.alert-error" within 2 seconds
        And I should see "The form contains invalid entries" within 1 seconds
        And I should see an element with the css selector "span.error-block" within 1 seconds
        And I should see "Description cannot be empty" within 1 seconds

    Scenario Outline: Data request creator and Sysadmin can see a 'Close' button on the data request detail page for opened data requests
        Given "<User>" as the persona
        When I log in and go to the data requests page
        And I press "Test Request"
        Then I should see an element with xpath "//a[contains(string(), 'Close')]"

        Examples: Users
        | User                  |
        | SysAdmin              |

    Scenario Outline: Non admin users cannot see a 'Close' button on the data request detail page for opened data requests
        Given "<User>" as the persona
        When I log in and go to the data requests page
        And I press "Test Request"
        Then I should not see an element with xpath "//a[contains(string(), 'Close')]"

        Examples: Users
        | User                  |
        | CKANUser              |
        | DataRequestOrgEditor  |
        | DataRequestOrgMember  |
        | TestOrgEditor         |
        | TestOrgMember         |

    Scenario: Creating a new data request will show the data request afterward
        Given "TestOrgEditor" as the persona
        When I log in and create a datarequest
        Then I should see an element with xpath "//i[contains(@class, 'icon-unlock')]"
        And I should see an element with xpath "//a[contains(string(), 'Close')]"

    Scenario: Closing a data request will show the data request afterward
        Given "DataRequestOrgAdmin" as the persona
        When I log in and create a datarequest
        And I press the element with xpath "//a[contains(string(), 'Close')]"
        And I select "Requestor initiated closure" from "close_circumstance"
        And I press the element with xpath "//button[contains(@class, 'btn-danger') and contains(string(), 'Close data request')]"
        Then I should see an element with xpath "//i[contains(@class, 'icon-lock')]"
        And I should not see an element with xpath "//a[contains(string(), 'Close')]"

    Scenario: As an org admin I can re-open a closed data request
        Given "DataRequestOrgAdmin" as the persona
        When I log in and create a datarequest
        And I press the element with xpath "//a[contains(string(), 'Close')]"
        And I select "Requestor initiated closure" from "close_circumstance"
        And I press the element with xpath "//button[contains(@class, 'btn-danger') and contains(string(), 'Close data request')]"
        Then I should see an element with xpath "//a[contains(string(), 'Re-open')]"
        When I press the element with xpath "//a[contains(string(), 'Re-open')]"
        Then I should see an element with xpath "//i[contains(@class, 'icon-unlock')]"
        And I should see an element with xpath "//a[contains(string(), 'Close')]"
