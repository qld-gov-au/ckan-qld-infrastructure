@reporting
@OpenData
Feature: Reporting

    @unauthenticated
    Scenario: I can view a 'Broken Links' report anonymously
        Given "Unauthenticated" as the persona
        When I visit "/report"
        And I press "Broken links"
        Then I should see an element with xpath "//select[@name='organization']"
        And I should see an element with xpath "//table[@id='report-table']//th[contains(string(), 'Broken datasets')]"
        And I should see an element with xpath "//table[@id='report-table']//th[contains(string(), 'Broken links')]"
        And I should see an element with xpath "//table[@id='report-table']//td[position()=1]/a[contains(@href, 'report/broken-links') and contains(string(), 'Test Organisation')]"

        When I press "Test Organisation"
        # There may not be an org with broken links, but we can at least check we've reached the org page
        Then I should see an element with xpath "//a[@href="/report/broken-links" and string() = 'Index of all organizations']"
        And I should not see an element with xpath "//table[@id='report-table']//th[contains(string(), 'Percent broken')]"

        When I go back
        Then I should see an element with xpath "//select[@name='organization']"
        When I select "test-organisation" from "organization"
        Then I should see an element with xpath "//a[@href="/report/broken-links" and string() = 'Index of all organizations']"
        And I should not see an element with xpath "//table[@id='report-table']//th[contains(string(), 'Percent broken')]"

    @unauthenticated
    Scenario: I can view a 'Data Usability Rating' report anonymously
        Given "Unauthenticated" as the persona
        When I visit "/report"
        And I press "Data usability rating"
        Then I should see an element with xpath "//select[@name='organization']"
        And I should see an element with xpath "//table[@id='report-table']//th[string() = 'Score TBC']"
        And I should see an element with xpath "//table[@id='report-table']//th[string() = 'Average score']"
        And I should see an element with xpath "//table[@id='report-table']//td[position()=1]/a[contains(@href, 'report/openness') and contains(string(), 'Test Organisation')]"

        When I press "Test Organisation"
        Then I should see an element with xpath "//table[@id='report-table']//th[string() = 'Dataset']"
        And I should see an element with xpath "//table[@id='report-table']//th[string() = 'Notes']"
        And I should see an element with xpath "//table[@id='report-table']//th[string() = 'Score']"
        And I should see an element with xpath "//table[@id='report-table']//th[string() = 'Reason']"

        When I go back
        Then I should see an element with xpath "//select[@name='organization']"
        When I select "test-organisation" from "organization"
        Then I should see an element with xpath "//table[@id='report-table']//th[string() = 'Dataset']"
        And I should see an element with xpath "//table[@id='report-table']//th[string() = 'Notes']"
        And I should see an element with xpath "//table[@id='report-table']//th[string() = 'Score']"
        And I should see an element with xpath "//table[@id='report-table']//th[string() = 'Reason']"
