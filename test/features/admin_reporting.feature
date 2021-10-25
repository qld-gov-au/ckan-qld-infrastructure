
@reporting
@OpenData

Feature: AdminReporting

    Scenario: As an admin user of my organisation, I can view 'My Reports' tab in the dashboard and show the 'Admin Report' with filters and table columns
        Given "TestOrgAdmin" as the persona
        When I log in
        And I visit "dashboard"
        And I click the link with text that contains "My Reports"
        And I click the link with text that contains "Admin Report"
        Then I should see an element with id "organisation"
        When I press the element with xpath "//button[contains(string(), 'Show')]"
        Then I should see "Organisation: Test Organisation" within 1 seconds
        Then I should see an element with xpath "//tr/th[string()='Criteria' and position()=1]"
        Then I should see an element with xpath "//tr/th[string()='Figure' and position()=2]"


    Scenario: As an editor user of my organisation, I can view 'My Reports' tab in the dashboard but I cannot view the 'Admin Report' link
        Given "TestOrgEditor" as the persona
        When I log in
        And I visit "dashboard"
        And I click the link with text that contains "My Reports"
        Then I should not see an element with xpath "//a[contains(string(), 'Admin Report')]"


    Scenario: As an admin user of my organisation, when I view my admin report, I can verify the de-identified datasets row exists
        Given "TestOrgAdmin" as the persona
        When I log in
        And I go to my reports page
        And I click the link with text that contains "Admin Report"
        And I press the element with xpath "//button[contains(string(), 'Show')]"
        Then I should see an element with xpath "//tr[@id='de-identified-datasets']/td[contains(@class, 'metric-title') and contains(string(), 'De-identified Datasets') and position()=1]"
        Then I should see an element with xpath "//tr[@id='de-identified-datasets']/td[contains(@class, 'metric-data') and position()=2]"

    Scenario: As an admin user of my organisation, when I view my admin report, I can verify the overdue datasets row exists correct
        Given "TestOrgAdmin" as the persona
        When I log in
        And I go to my reports page
        And I click the link with text that contains "Admin Report"
        And I press the element with xpath "//button[contains(string(), 'Show')]"
        Then I should see an element with xpath "//tr[@id='overdue-datasets']/td[contains(@class, 'metric-title') and contains(string(), 'Overdue Datasets') and position()=1]"
        Then I should see an element with xpath "//tr[@id='overdue-datasets']/td[contains(@class, 'metric-data') and position()=2]"
