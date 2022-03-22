@reporting
@OpenData
Feature: Engagement Reporting

    Scenario Outline: As a user with admin or editor role capacity of an organisation, I can view 'My Reports' tab in the dashboard and show the engagement report with filters
        Given "<User>" as the persona
        When I log in
        And I visit "dashboard"
        And I click the link with text that contains "My Reports"
        And I click the link with text that contains "Engagement Report"
        Then I should see an element with id "organisation"
        And I should see an element with id "start_date"
        And I fill in "start_date" with "01-01-2019"
        And I should see an element with id "end_date"
        And I fill in "end_date" with "01-01-2020"
        When I press the element with xpath "//button[contains(string(), 'Show')]"
        Then I should see "Organisation: Test Organisation" within 1 seconds
        And I should see "01/01/2019 - 01/01/2020" within 1 seconds

        Examples: Users
            | User          |
            | TestOrgAdmin  |
            | TestOrgEditor |


    Scenario: As a data request organisation admin, when I view my engagement report, I can verify the number of data requests is correct and increments
        Given "DataRequestOrgAdmin" as the persona
        When I log in
        And I go to my reports page
        And I click the link with text that contains "Engagement Report"
        And I press the element with xpath "//button[contains(string(), 'Show')]"
        Then I should see an element with xpath "//tr[@id='datarequests-total']/td[contains(@class, 'metric-title') and string()='Data requests' and position()=1]"
        Then I should see an element with xpath "//tr[@id='datarequests-total']/td[contains(@class, 'metric-data') and string()='3' and position()=2]"
        When I create a datarequest
        And I go to my reports page
        And I click the link with text that contains "Engagement Report"
        And I press the element with xpath "//button[contains(string(), 'Show')]"
        Then I should see an element with xpath "//tr[@id='datarequests-total']/td[contains(@class, 'metric-title') and string()='Data requests' and position()=1]"
        Then I should see an element with xpath "//tr[@id='datarequests-total']/td[contains(@class, 'metric-data') and string()='4' and position()=2]"


    Scenario: As an admin user of my organisation, when I view my engagement report, I can verify the number of dataset followers is correct and increments
        Given "ReportingOrgAdmin" as the persona
        When I log in
        And I go to my reports page
        And I click the link with text that contains "Engagement Report"
        And I press the element with xpath "//button[contains(string(), 'Show')]"
        Then I should see an element with xpath "//tr[@id='dataset-followers']/td[contains(@class, 'metric-title') and string()='Dataset followers' and position()=1]"
        Then I should see an element with xpath "//tr[@id='dataset-followers']/td[contains(@class, 'metric-data') and string()='0' and position()=2]"
        When I go to dataset "reporting"
        And I press the element with xpath "//a[@class='btn btn-success' and contains(string(), 'Follow')]"
        And I go to my reports page
        And I click the link with text that contains "Engagement Report"
        Then I should see an element with xpath "//tr[@id='dataset-followers']/td[contains(@class, 'metric-title') and string()='Dataset followers' and position()=1]"
        Then I should see an element with xpath "//tr[@id='dataset-followers']/td[contains(@class, 'metric-data') and string()='1' and position()=2]"


    Scenario: As an admin user of my organisation, when I view my engagement report, I can verify the number of dataset comments is correct and increments
        Given "ReportingOrgAdmin" as the persona
        When I log in
        And I go to my reports page
        And I click the link with text that contains "Engagement Report"
        And I press the element with xpath "//button[contains(string(), 'Show')]"
        Then I should see an element with xpath "//tr[@id='dataset-comments']/td[contains(@class, 'metric-title') and string()='Dataset comments' and position()=1]"
        Then I should see an element with xpath "//tr[@id='dataset-comments']/td[contains(@class, 'metric-data') and string()='0' and position()=2]"
        When I go to dataset "reporting" comments
        And I submit a comment with subject "Test subject" and comment "This is a test comment"
        And I go to my reports page
        And I click the link with text that contains "Engagement Report"
        Then I should see an element with xpath "//tr[@id='dataset-comments']/td[contains(@class, 'metric-title') and string()='Dataset comments' and position()=1]"
        Then I should see an element with xpath "//tr[@id='dataset-comments']/td[contains(@class, 'metric-data') and string()='1' and position()=2]"


    Scenario: As an admin user of my organisation, when I view my engagement report, I can verify the number of data request comments is correct and increments
        Given "ReportingOrgAdmin" as the persona
        When I log in
        And I go to my reports page
        And I click the link with text that contains "Engagement Report"
        And I press the element with xpath "//button[contains(string(), 'Show')]"
        Then I should see an element with xpath "//tr[@id='datarequest-comments']/td[contains(@class, 'metric-title') and string()='Data request comments' and position()=1]"
        Then I should see an element with xpath "//tr[@id='datarequest-comments']/td[contains(@class, 'metric-data') and string()='0' and position()=2]"
        When I go to data request "Reporting Request" comments
        And I submit a comment with subject "Test subject" and comment "This is a test comment"
        And I go to my reports page
        And I click the link with text that contains "Engagement Report"
        Then I should see an element with xpath "//tr[@id='datarequest-comments']/td[contains(@class, 'metric-title') and string()='Data request comments' and position()=1]"
        Then I should see an element with xpath "//tr[@id='datarequest-comments']/td[contains(@class, 'metric-data') and string()='1' and position()=2]"
