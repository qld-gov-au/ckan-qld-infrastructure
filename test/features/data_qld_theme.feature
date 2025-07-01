@theme
Feature: Theme customisations (Publications and OpenData)

    @unauthenticated
    Scenario: As a member of the public, when I go to the consistent asset URLs, I can see the asset
        Given "Unauthenticated" as the persona
        When I visit "/assets/css/main"
        Then I should see "Bootstrap"
        When I visit "/assets/css/font-awesome"
        Then I should see "Font Awesome"
        When I visit "/assets/css/select2"
        Then I should see "select2-container"
        When I visit "/assets/js/jquery"
        Then I should see "jQuery"

    @unauthenticated
    Scenario: As a member of the public, when I go to api get urls, I can see a valid response
        Given "Unauthenticated" as the persona
        When I visit "/api/3/action/package_search?q=a"
        Then I should see "/api/3/action/help_show?name=package_search", "success": true, "result":"

    @unauthenticated
    Scenario: Lato font is implemented on homepage
        Given "Unauthenticated" as the persona
        When I go to homepage
        Then I should see an element with xpath "//link[contains(@href,'https://fonts.googleapis.com/css?family=Lato')]"

    @unauthenticated
    Scenario: Organisation is in fact spelled Organisation (as opposed to Organization)
        Given "Unauthenticated" as the persona
        When I go to organisation page
        Then I should see "Organisation"
        And I should not see "Organization"

    Scenario: When I create an organisation without a description, the display should not mention its absence
        Given "SysAdmin" as the persona
        When I log in
        And I go to organisation page
        And I press "Add Organisation"
        Then I should see "Create an Organisation"
        When I execute the script "$('#field-name').val('Org without description')"
        And I execute the script "$('#field-url').val('org-without-description')"
        And I press the element with xpath "//button[contains(@class, 'btn-primary')]"
        Then I should see "Org without description"
        And I should see "No datasets found"
        And I should not see "There is no description"

    Scenario: When I create an organisation with a description, there should be a Read More link
        Given "SysAdmin" as the persona
        When I log in
        And I go to organisation page
        And I press "Add Organisation"
        Then I should see "Create an Organisation"
        When I execute the script "$('#field-name').val('Org with description')"
        And I execute the script "$('#field-url').val('org-with-description')"
        And I fill in "description" with "Some description or other"
        And I press the element with xpath "//button[contains(@class, 'btn-primary')]"
        Then I should see "Org with description"
        And I should see "No datasets found"
        And I should see "Some description or other"
        And I should see an element with xpath "//a[string() = 'read more' and contains(@href, '/organization/about/org-with-description')]"

    @unauthenticated
    Scenario: Explore button does not exist on dataset detail page
        Given "Unauthenticated" as the persona
        When I go to dataset "public-test-dataset"
        Then I should not see "Explore"

    @unauthenticated
    Scenario: As a member of the public, I should be able to see the help text on the organisation page
        Given "Unauthenticated" as the persona
        When I go to organisation page
        Then I should see "Organisations are Queensland Government departments, other agencies or legislative entities responsible for publishing open data on this portal."

    @OpenData
    Scenario: As a publisher, when I create a resource with an API entry, I can download it in various formats
        Given "TestOrgEditor" as the persona
        When I log in
        And I create a dataset and resource with key-value parameters "license=other-open" and "format=CSV::upload=csv_resource.csv"
        And I wait for 10 seconds
        And I press "Test Resource"
        Then I should see an element with xpath "//a[contains(string(), 'Data API')]"
        And I should see an element with xpath "//button[contains(@class, 'dropdown-toggle')]"
        And I should see an element with xpath "//a[contains(@class, 'resource-btn') and contains(@href, '/download/csv_resource.csv') and contains(string(), '(CSV)')]"
        When I press the element with xpath "//button[contains(@class, 'dropdown-toggle')]"
        Then I should see an element with xpath "//a[contains(@href, '/datastore/dump/') and contains(string(), 'CSV')]"
        And I should see an element with xpath "//a[contains(@href, '/datastore/dump/') and contains(@href, 'format=tsv') and contains(string(), 'TSV')]"
        And I should see an element with xpath "//a[contains(@href, '/datastore/dump/') and contains(@href, 'format=json') and contains(string(), 'JSON')]"
        And I should see an element with xpath "//a[contains(@href, '/datastore/dump/') and contains(@href, 'format=xml') and contains(string(), 'XML')]"

    @unauthenticated
    @OpenData
    Scenario: Open Data - Menu items are present and correct
        Given "Unauthenticated" as the persona
        When I go to dataset page
        Then I should see an element with xpath "//li[contains(@class, 'active')]/a[contains(string(), 'Data') and (@href='/dataset' or @href='/dataset/')]"
        And I should see an element with xpath "//li[not(contains(@class, 'active'))]/a[contains(string(), 'Visualisations') and @href='/visualisations']"
        And I should see an element with xpath "//li[not(contains(@class, 'active'))]/a[contains(string(), 'News and Case Studies') and @href='/news-and-case-studies']"
        And I should see an element with xpath "//li[not(contains(@class, 'active'))]/a[contains(string(), 'Standards and guidance') and @href='/article/standards-and-guidance']"
        And I should see an element with xpath "//li[not(contains(@class, 'active'))]/a[contains(string(), 'Contact') and @href='/article/contact']"

    @unauthenticated
    @Publications
    Scenario: Publications - Menu items are present and correct
        Given "Unauthenticated" as the persona
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

    @unauthenticated
    Scenario: When I encounter a 'resource not found' error page, it has a custom message
        Given "Unauthenticated" as the persona
        When I go to "/dataset/nonexistent/resource/nonexistent"
        Then I should see "Sorry, the page you were looking for could not be found."

        When I go to "/nonexistent"
        Then I should see an element with xpath "//div[contains(string(), 'was not found') or contains(string(), 'could not be found')]"
        And I should not see "Sorry, the page you were looking for could not be found."

    @unauthenticated
    Scenario: When I go to the header URL, I can see the list of necessary assets
        Given "Unauthenticated" as the persona
        When I go to "/header.html"
        Then I should see an element with xpath "//a[@href='/user/login' and contains(string(), 'Log in')]"
        And I should see an element with xpath "//a[@href='/user/register' and contains(string(), 'Register')]"
        And I should not see "not found"

    @unauthenticated
    @OpenData
    Scenario: When I go to the header URL, I can see the data request link
        Given "Unauthenticated" as the persona
        When I go to "/header.html"
        Then I should see an element with xpath "//a[@href='/datarequest' and contains(string(), 'Request data')]"

    @unauthenticated
    Scenario: When I go to the robots file, I can see a custom disallow block
        Given "Unauthenticated" as the persona
        When I go to "/robots.txt"
        Then I should see "Disallow: /"
        And I should not see "Allow:"
