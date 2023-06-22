Feature: Dataset APIs

    Scenario: Creative Commons BY-NC-SA 4.0 licence is an option for datasets
        Given "SysAdmin" as the persona
        When I log in
        And I edit the "test-dataset" dataset
        Then I should see an element with xpath "//option[@value='cc-by-nc-sa-4']"

    Scenario: As a publisher, I can view the change history of a dataset
        Given "TestOrgEditor" as the persona
        When I log in
        And I edit the "public-test-dataset" dataset
        And I fill in "author_email" with "admin@example.com"
        And I press the element with xpath "//form[@id='dataset-edit']//button[contains(@class, 'btn-primary')]"
        And I press the element with xpath "//a[contains(@href, '/dataset/activity/') and contains(string(), 'Activity Stream')]"
        Then I should see "created the dataset"
        When I press "View this version"
        Then I should see "You're currently viewing an old version of this dataset."
        When I go to dataset "public-test-dataset"
        And I press the element with xpath "//a[contains(@href, '/dataset/activity/') and contains(string(), 'Activity Stream')]"
        And I press "Changes"
        Then I should see "View changes from"
        And I should see an element with xpath "//select[@name='old_id']"
        And I should see an element with xpath "//select[@name='new_id']"
