@OpenData
Feature: XLoader

    @unauthenticated
    Scenario: As a member of the public, when I visit a resource with a datastore entry, I can see the data preview
        Given "Unauthenticated" as the persona
        When I go to dataset "public-test-dataset"
        And I press "test-csv-resource"
        Then I should see "SomeTown"
        And I should not see "DataStore"

    Scenario: As a publisher, when I visit a resource I control with a datastore entry, I can access the XLoader interface
        Given "TestOrgEditor" as the persona
        When I log in
        And I go to dataset "public-test-dataset"
        And I press "test-csv-resource"
        Then I should see "SomeTown"
        And I should see "DataStore"

        When I press "DataStore"
        Then I should see "Data Schema"
        And I should see "Data Dictionary"
        And I should see "Upload to DataStore"
        And I should see "Delete from DataStore"
        And I should see "Status"
        And I should see "Complete"
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
        And I should not see an element with xpath "//a[contains(@href, '/dictionary/')"
