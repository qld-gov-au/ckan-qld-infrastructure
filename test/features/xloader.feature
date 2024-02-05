@OpenData
@XLoader
Feature: XLoader

    Scenario: As a publisher, when I visit a resource I control with a datastore entry, I can access the XLoader interface
        Given "TestOrgEditor" as the persona
        When I log in
        And I create a dataset and resource with key-value parameters "notes=Testing XLoader" and "name=test-csv-resource::url=https://people.sc.fsu.edu/~jburkardt/data/csv/addresses.csv::format=CSV"
        # Wait for XLoader to run
        And I wait for 10 seconds
        And I press "test-csv-resource"
        Then I should see "DataStore"

        When I press "DataStore"
        Then I should see "Express Load completed"
        And I should see "Data Schema"
        And I should see "Data Dictionary"
        And I should see "Upload to DataStore"
        And I should see "Delete from DataStore"
        And I should see "Status"
        And I should see "Last updated"
        And I should see "Upload Log"
        And I should see "View resource"

        When I press "Upload to DataStore"
        Then I should see "Status"
        And I should see "Pending"
        And I should see "Delete from DataStore"

        When I press "Delete from DataStore"
        And I confirm the dialog containing "delete the DataStore" if present
        Then I should see "DataStore and Data Dictionary deleted for resource"
        And I should see "Upload to DataStore"
        And I should not see "Delete from DataStore"
        And I should not see an element with xpath "//a[contains(@href, '/dictionary/')]"
