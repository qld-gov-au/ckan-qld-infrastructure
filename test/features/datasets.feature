Feature: Dataset APIs

    Scenario: Creative Commons BY-NC-SA 4.0 licence is an option for datasets
        Given "SysAdmin" as the persona
        When I log in
        And I edit the "test-dataset" dataset
        Then I should see an element with xpath "//option[@value='cc-by-nc-sa-4']"

    Scenario: As a publisher, I can view the change history of a dataset
        Given "TestOrgEditor" as the persona
        When I log in
        And I create a dataset and resource with key-value parameters "notes=Testing activity stream" and "name=Test"
        And I press the element with xpath "//a[contains(@href, '/dataset/activity/') and contains(string(), 'Activity Stream')]"
        Then I should see "created the dataset"
        When I press "View this version"
        Then I should see "You're currently viewing an old version of this dataset."
        When I go to dataset "$last_generated_name"
        And I press the element with xpath "//a[contains(@href, '/dataset/activity/') and contains(string(), 'Activity Stream')]"
        And I press "Changes"
        Then I should see "View changes from"
        And I should see an element with xpath "//select[@name='old_id']"
        And I should see an element with xpath "//select[@name='new_id']"
