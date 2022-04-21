Feature: Theme customisations

    Scenario: Lato font is implemented on homepage
        When I go to homepage
        Then I should see an element with xpath "//link[contains(@href,'https://fonts.googleapis.com/css?family=Lato')]"

    Scenario: Organisation is in fact spelled Organisation (as opposed to Organization) 
        When I go to organisation page
        Then I should see "Organisation"
        And I should not see "Organization"

    Scenario: When I create an organisation without a description, the display should not mention its absence
        Given "SysAdmin" as the persona
        When I log in
        And I go to organisation page
        And I click the link with text that contains "Add Organisation"
        Then I should see "Create an Organisation"
        When I fill in "title" with "Org without description"
        And I press the element with xpath "//button[contains(@class, 'btn-primary')]"
        Then I should see "Org without description"
        And I should see "No datasets found"
        And I should not see "There is no description"

    Scenario: When I create an organisation with a description, there should be a Read More link
        Given "SysAdmin" as the persona
        When I log in
        And I go to organisation page
        And I click the link with text that contains "Add Organisation"
        Then I should see "Create an Organisation"
        When I fill in "title" with "Org with description"
        And I fill in "description" with "Some description or other"
        And I press the element with xpath "//button[contains(@class, 'btn-primary')]"
        Then I should see "Org with description"
        And I should see "No datasets found"
        And I should see "Some description or other"
        And I should see an element with xpath "//a[string() = 'read more' and contains(@href, '/organization/about/org-with-description')]"

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

    @OpenData
    Scenario: As a publisher, when I create a resource with an API entry, I can download it in various formats
        Given "TestOrgEditor" as the persona
        When I log in
        And I resize the browser to 1024x2048
        And I create a dataset with license "other-open" and "CSV" resource file "csv_resource.csv"
        And I wait for 10 seconds
        And I click the link with text that contains "Test Resource"
        Then I should see an element with xpath "//a[contains(@class, 'resource-btn') and contains(@href, '/download/csv_resource.csv') and contains(string(), '(CSV)')]"
        When I press the element with xpath "//button[@data-toggle='dropdown']"
        Then I should see an element with xpath "//a[contains(@href, '/datastore/dump/') and contains(string(), 'CSV')]"
        Then I should see an element with xpath "//a[contains(@href, '/datastore/dump/') and contains(@href, 'format=tsv') and contains(string(), 'TSV')]"
        Then I should see an element with xpath "//a[contains(@href, '/datastore/dump/') and contains(@href, 'format=json') and contains(string(), 'JSON')]"
        Then I should see an element with xpath "//a[contains(@href, '/datastore/dump/') and contains(@href, 'format=xml') and contains(string(), 'XML')]"

    @Publications
    Scenario: Menu items are present and correct
        When I go to "/dataset"
        Then I should see an element with xpath "//li[contains(@class, 'active')]/a[contains(string(), 'Publication') and (@href='/dataset' or @href='/dataset/')]"
        And I should see an element with xpath "//li[not(contains(@class, 'active'))]/a[contains(string(), 'Standards') and @href='/dataset/publishing-standards-publications-qld-gov-au']"
        And I should see an element with xpath "//li[not(contains(@class, 'active'))]/a[contains(string(), 'Organisations') and @href='/organization']"
        And I should see an element with xpath "//li[not(contains(@class, 'active'))]/a[contains(string(), 'Gazettes') and @href='/gazettes-current']"
        And I should see an element with xpath "//li[not(contains(@class, 'active'))]/a[contains(string(), 'Contact') and @href='https://www.qld.gov.au/contact-us']"

        When I press the element with xpath "//a[contains(string(), 'Standards') and @href='/dataset/publishing-standards-publications-qld-gov-au']"
        Then I should see an element with xpath "//li[not(contains(@class, 'active'))]/a[contains(string(), 'Publication') and (@href='/dataset' or @href='/dataset/')]"
        And I should see an element with xpath "//li[contains(@class, 'active')]/a[contains(string(), 'Standards') and @href='/dataset/publishing-standards-publications-qld-gov-au']"
        And I should see an element with xpath "//li[not(contains(@class, 'active'))]/a[contains(string(), 'Organisations') and @href='/organization']"
        And I should see an element with xpath "//li[not(contains(@class, 'active'))]/a[contains(string(), 'Gazettes') and @href='/gazettes-current']"
        And I should see an element with xpath "//li[not(contains(@class, 'active'))]/a[contains(string(), 'Contact') and @href='https://www.qld.gov.au/contact-us']"

        When I press the element with xpath "//a[contains(string(), 'Organisations') and @href='/organization']"
        Then I should see an element with xpath "//li[not(contains(@class, 'active'))]/a[contains(string(), 'Publication') and (@href='/dataset' or @href='/dataset/')]"
        And I should see an element with xpath "//li[not(contains(@class, 'active'))]/a[contains(string(), 'Standards') and @href='/dataset/publishing-standards-publications-qld-gov-au']"
        And I should see an element with xpath "//li[contains(@class, 'active')]/a[contains(string(), 'Organisations') and @href='/organization']"
        And I should see an element with xpath "//li[not(contains(@class, 'active'))]/a[contains(string(), 'Gazettes') and @href='/gazettes-current']"
        And I should see an element with xpath "//li[not(contains(@class, 'active'))]/a[contains(string(), 'Contact') and @href='https://www.qld.gov.au/contact-us']"

        When I go to "/group/gazettes-test"
        Then I should see an element with xpath "//li[not(contains(@class, 'active'))]/a[contains(string(), 'Publication') and (@href='/dataset' or @href='/dataset/')]"
        And I should see an element with xpath "//li[not(contains(@class, 'active'))]/a[contains(string(), 'Standards') and @href='/dataset/publishing-standards-publications-qld-gov-au']"
        And I should see an element with xpath "//li[not(contains(@class, 'active'))]/a[contains(string(), 'Organisations') and @href='/organization']"
        And I should see an element with xpath "//li[contains(@class, 'active')]/a[contains(string(), 'Gazettes') and @href='/gazettes-current']"
        And I should see an element with xpath "//li[not(contains(@class, 'active'))]/a[contains(string(), 'Contact') and @href='https://www.qld.gov.au/contact-us']"

    Scenario: When I encounter a 'resource not found' error page, it has a custom message
        When I go to "/dataset/nonexistent/resource/nonexistent"
        Then I should see "Sorry, the page you were looking for could not be found."

        When I go to "/nonexistent"
        Then I should see an element with xpath "//div[contains(string(), 'was not found') or contains(string(), 'could not be found')]"
        And I should not see "Sorry, the page you were looking for could not be found."

    Scenario: When I go to the header URL, I can see the list of necessary assets
        When I go to "/header.html"
        Then I should see an element with xpath "//a[@href='/user/login' and contains(string(), 'Log in')]"
        And I should see an element with xpath "//a[@href='/user/register' and contains(string(), 'Register')]"
        And I should see an element with xpath "//a[@href='/datarequest' and contains(string(), 'Request data')]"
        And I should not see "not found"
