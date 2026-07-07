@reporting
@OpenData
@multi_plugin
Feature: Reporting

    @unauthenticated
    Scenario: I can view a 'Broken Links' report anonymously
        Given "Unauthenticated" as the persona
        When I visit "/report"
        And I expand the browser height
        And I press "Broken links"
        And I take a debugging screenshot
        Then I should see an element with xpath "//select[@name='organization']"
        And I should see an element with xpath "//table[@id='report-table']//th[contains(string(), 'Broken datasets')]"
        And I should see an element with xpath "//table[@id='report-table']//th[contains(string(), 'Broken links')]"
        And I should see an element with xpath "//table[@id='report-table']//td[position()=1]/a[contains(@href, 'report/broken-links') and contains(string(), 'Test Organisation')]"

        When I press the element with xpath "//table[@id='report-table']//a[contains(string(), 'Test Organisation')]"
        And I take a debugging screenshot
        Then I should see an element with xpath "//table[@id='report-table']//th[string() = 'Res']"
        And I should see an element with xpath "//table[@id='report-table']//th[string() = 'URL']"
        And I should see an element with xpath "//table[@id='report-table']//th[string() = 'Status']"
        And I should see an element with xpath "//table[@id='report-table']//th[string() = 'Reason']"

        When I go back
        And I take a debugging screenshot
        Then I should see an element with xpath "//select[@name='organization']"
        When I select "test-organisation" from "organization"
        Then I should see an element with xpath "//table[@id='report-table']//th[string() = 'Res']"
        And I should see an element with xpath "//table[@id='report-table']//th[string() = 'URL']"
        And I should see an element with xpath "//table[@id='report-table']//th[string() = 'Status']"
        And I should see an element with xpath "//table[@id='report-table']//th[string() = 'Reason']"

    @unauthenticated
    Scenario: I can view a 'Data Usability Rating' report anonymously
        Given "Unauthenticated" as the persona
        When I visit "/report"
        And I expand the browser height
        And I press "Data usability rating"
        And I take a debugging screenshot
        Then I should see an element with xpath "//select[@name='organization']"
        And I should see an element with xpath "//table[@id='report-table']//th[string() = 'Score TBC']"
        And I should see an element with xpath "//table[@id='report-table']//th[string() = 'Average score']"
        And I should see an element with xpath "//table[@id='report-table']//td[position()=1]/a[contains(@href, 'report/openness') and contains(string(), 'Test Organisation')]"

        When I press the element with xpath "//table[@id='report-table']//a[contains(string(), 'Test Organisation')]"
        And I take a debugging screenshot
        Then I should see an element with xpath "//table[@id='report-table']//th[string() = 'Dataset']"
        And I should see an element with xpath "//table[@id='report-table']//th[string() = 'Notes']"
        And I should see an element with xpath "//table[@id='report-table']//th[string() = 'Score']"
        And I should see an element with xpath "//table[@id='report-table']//th[string() = 'Reason']"

        When I go back
        And I take a debugging screenshot
        Then I should see an element with xpath "//select[@name='organization']"
        When I select "test-organisation" from "organization"
        Then I should see an element with xpath "//table[@id='report-table']//th[string() = 'Dataset']"
        And I should see an element with xpath "//table[@id='report-table']//th[string() = 'Notes']"
        And I should see an element with xpath "//table[@id='report-table']//th[string() = 'Score']"
        And I should see an element with xpath "//table[@id='report-table']//th[string() = 'Reason']"
