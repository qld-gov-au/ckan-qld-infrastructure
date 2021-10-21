@google-analytics
Feature: GoogleAnalytics

    Scenario: When viewing the HTML source code of a CKAN page, the GTM snippet is visible
        When I go to homepage
        Then I should see an element with xpath "//script[@src='//www.googletagmanager.com/gtm.js?id=False']"

    Scenario: When viewing the HTML source code of a dataset, the organisation meta data is visible
        When I go to Dataset page
        And I click the link with text that contains "Department of Health Spend Data"
        Then I should see an element with xpath "//meta[@name='DCTERMS.creator' and @content='c=AU; o=The State of Queensland; ou=Department of Health' and @scheme='AGLSTERMS.GOLD']"

    Scenario: When viewing the HTML source code of a resource, the organisation meta data is visible
        When I go to Dataset page
        And I click the link with text that contains "A Novel By Tolstoy"
        And I click the link with text that contains "Full text"
        Then I should see an element with xpath "//meta[@name='DCTERMS.creator' and @content='c=AU; o=The State of Queensland; ou=Test Organisation' and @scheme='AGLSTERMS.GOLD']"
