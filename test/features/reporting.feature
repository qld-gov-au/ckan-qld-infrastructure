@OpenData
@reporting
Feature: Reporting

    @unauthenticated
    Scenario: I can view a 'Broken Links' report anonymously
        Given "Unauthenticated" as the persona
        When I visit "/report"
        And I click the link with text that contains "Broken links"
        Then I should see an element with xpath "//select[@name='organization']"
        And I should see an element with xpath "//table[@id='report-table']//th[contains(string(), 'Broken datasets')]"
        And I should see an element with xpath "//table[@id='report-table']//th[contains(string(), 'Broken links')]"
        And I should see an element with xpath "//table[@id='report-table']//td[position()=1]/a[contains(@href, 'report/broken-links') and contains(string(), 'Test Organisation')]"

    @unauthenticated
    Scenario: I can view a 'Data Usability Rating' report anonymously
        Given "Unauthenticated" as the persona
        When I visit "/report"
        And I click the link with text that contains "Data usability rating"
        Then I should see an element with xpath "//select[@name='organization']"
        And I should see an element with xpath "//table[@id='report-table']//th[contains(string(), 'Score TBC')]"
        And I should see an element with xpath "//table[@id='report-table']//th[contains(string(), 'Average score')]"
        And I should see an element with xpath "//table[@id='report-table']//td[position()=1]/a[contains(@href, 'report/openness') and contains(string(), 'Test Organisation')]"
