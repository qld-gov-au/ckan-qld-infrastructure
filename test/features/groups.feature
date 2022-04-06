@users
Feature: Group APIs

    Scenario Outline: Group membership is accessible to admins of the group
        Given "<Persona>" as the persona
        When I log in
        And I view the "silly-walks" group API "including" users
        Then I should see an element with xpath "//*[contains(string(), '"success": true,') and contains(string(), '"name": "group_admin"') and contains(string(), '"name": "walker"')]"

        Examples: Admins
            | Persona      |
            | SysAdmin     |
            | Group Admin  |

    Scenario Outline: Group membership is not accessible to non-admins
        Given "<Persona>" as the persona
        When I log in
        And I view the "silly-walks" group API "including" users
        Then I should see an element with xpath "//*[contains(string(), '"success": false,') and contains(string(), 'Authorization Error')]"

        Examples: Non-admin users
            | Persona             |
            | Organisation Admin  |
            | Walker              |

    Scenario: Group membership is not accessible anonymously
        When I view the "silly-walks" group API "including" users
        Then I should see an element with xpath "//*[contains(string(), '"success": false,') and contains(string(), 'Authorization Error')]"

    Scenario: Group overview is accessible to everyone
        When I go to "/group"
        Then I should see "silly-walks"
        When I view the "silly-walks" group API "not including" users
        Then I should see an element with xpath "//*[contains(string(), '"success": true,') and contains(string(), '"name": "silly-walks"')]"
