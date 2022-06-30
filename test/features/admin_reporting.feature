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
        And I should see an element with xpath "//tr/th[string()='Criteria' and position()=1]"
        And I should see an element with xpath "//tr/th[string()='Figure' and position()=2]"
        And I should be able to download via the element with xpath "//a[contains(string(), 'Export')]"

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
        And I should see an element with xpath "//tr[@id='overdue-datasets']/td[contains(@class, 'metric-data') and position()=2]"

    Scenario: As an admin user of my organisation, when I view my admin report, I can verify that datasets without groups are identified
        Given "Organisation Admin" as the persona
        When I log in
        And I go to my reports page
        And I click the link with text that contains "Admin Report"
        And I press the element with xpath "//button[contains(string(), 'Show')]"
        Then I should see an element with xpath "//tr[@id='datasets_no_groups']/td[contains(@class, 'metric-title') and position()=1]/a[contains(@href, 'datasets_no_groups?report_type=admin') and contains(string(), 'Datasets not added to group')]"
        And I should see an element with xpath "//tr[@id='datasets_no_groups']/td[contains(@class, 'metric-data') and position()=2]/a[contains(@href, 'datasets_no_groups?report_type=admin')]"

        When I click the link with text that contains "Datasets not added to group/s"
        Then I should see "Admin Report: Datasets not added to group/s: Department of Health"
        And I should see "Department of Health Spend Data"
        When I click the link with text that contains "Department of Health Spend Data"
        Then I should see "Department of Health Spend Data"
        And I should see "Data and Resources"

    Scenario: As an admin user of my organisation, when I view my admin report, I can verify that datasets without tags are identified
        Given "Organisation Admin" as the persona
        When I log in
        And I go to my reports page
        And I click the link with text that contains "Admin Report"
        And I press the element with xpath "//button[contains(string(), 'Show')]"
        Then I should see an element with xpath "//tr[@id='datasets_no_tags']/td[contains(@class, 'metric-title') and position()=1]/a[contains(@href, 'datasets_no_tags?report_type=admin') and contains(string(), 'Datasets with no tags')]"
        And I should see an element with xpath "//tr[@id='datasets_no_tags']/td[contains(@class, 'metric-data') and position()=2]/a[contains(@href, 'datasets_no_tags?report_type=admin')]"

        When I click the link with text that contains "Datasets with no tags"
        Then I should see "Admin Report: Datasets with no tags: Department of Health"
        And I should see "Department of Health Spend Data"
        When I click the link with text that contains "Department of Health Spend Data"
        Then I should see "Department of Health Spend Data"
        And I should see "Data and Resources"
