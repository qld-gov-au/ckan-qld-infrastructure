@groups
Feature: Group APIs

    Scenario Outline: Group membership is accessible to admins of the group
        Given "<Persona>" as the persona
        When I log in
        And I view the "silly-walks" group API "including" users
        Then I should see an element with xpath "//*[contains(string(), '"success": true') and contains(string(), '"name": "group_admin"') and contains(string(), '"name": "walker"')]"

        Examples: Admins
            | Persona      |
            | SysAdmin     |
            | Group Admin  |

    Scenario Outline: Group membership is not accessible to non-admins
        Given "<Persona>" as the persona
        When I log in
        And I view the "silly-walks" group API "including" users
        Then I should see an element with xpath "//*[contains(string(), '"success": false') and contains(string(), 'Authorization Error')]"

        Examples: Non-admin users
            | Persona       |
            | TestOrgAdmin  |
            | Walker        |

    @unauthenticated
    Scenario: Group membership is not accessible anonymously
        Given "Unauthenticated" as the persona
        When I view the "silly-walks" group API "including" users
        Then I should see an element with xpath "//*[contains(string(), '"success": false') and contains(string(), 'Authorization Error')]"

    @unauthenticated
    Scenario: Group overview is accessible to everyone
        Given "Unauthenticated" as the persona
        When I go to "/group"
        Then I should see "Silly walks"
        And I should not see an element with xpath "//a[contains(@href, '?action=read')]"
        And I should see an element with xpath "//a[contains(@href, '/group/silly-walks')]"

        When I view the "silly-walks" group API "not including" users
        Then I should see an element with xpath "//*[contains(string(), '"success": true') and contains(string(), '"name": "silly-walks"')]"

    Scenario: As a sysadmin, when I create a group with a long name, it should be preserved
        Given "SysAdmin" as the persona
        When I log in
        And I go to group page
        And I click the link to "/group/new"
        And I fill in title with random text starting with "Group name more than 35 characters"
        And I set "group_title" to "$last_generated_title"
        And I press the element with xpath "//button[contains(@class, 'btn-primary')]"
        And I take a debugging screenshot
        # Breadcrumb should be truncated but preserve full name in a tooltip
        Then I should see an element with xpath "//ol[contains(@class, 'breadcrumb')]//a[contains(string(), 'Group name more') and contains(string(), '...') and @title = '$group_title']"

        # Search facets should be truncated but preserve full name in a tooltip
        When I create a dataset and resource with key-value parameters "notes=Testing long group name" and "name=Test"
        And I press "Groups"
        When I select by text " $group_title" from "group_added"
        And I press the element with xpath "//button[contains(@class, 'btn-primary')]"
        Then I should see an element with xpath "//form//a[normalize-space() = '$group_title']"
        When I press "$group_title"

        Then I should see an element with xpath "//li[contains(@class, 'nav-item')]//a[contains(string(), 'Group name more') and contains(string(), '...') and @title = '$group_title']"
        When I press the element with xpath "//li[contains(@class, 'nav-item')]//a[contains(string(), 'Group name more') and contains(string(), '...') and @title = '$group_title']"
        Then I should see an element with xpath "//li[contains(@class, 'nav-item') and contains(@class, 'active')]//a[contains(string(), 'Group name more') and contains(string(), '...') and @title = '$group_title']"
