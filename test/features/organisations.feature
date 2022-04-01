@users
Feature: Organization APIs

    Scenario Outline: Organisation membership is accessible to admins of the organisation
        Given "<User>" as the persona
        When I log in
        And I view the "department-of-health" organisation API "including" users
        Then I should see an element with xpath "//*[contains(string(), '"success": true,') and contains(string(), '"name": "organisation_admin"') and contains(string(), '"name": "editor"')]"

        Examples: Admins
            | User                |
            | SysAdmin            |
            | Organisation Admin  |

    Scenario Outline: Organisation membership is not accessible to non-admins
        Given "<User>" as the persona
        When I log in
        And I view the "department-of-health" organisation API "including" users
        Then I should see an element with xpath "//*[contains(string(), '"success": false,') and contains(string(), 'Authorization Error')]"

        Examples: Non-admin users
            | User          |
            | Publisher     |
            | Foodie        |
            | Group Admin   |

    Scenario: Organisation membership is not accessible anonymously
        When I view the "department-of-health" organisation API "including" users
        Then I should see an element with xpath "//*[contains(string(), '"success": false,') and contains(string(), 'Authorization Error')]"

    Scenario: Organisation overview is accessible to everyone
        When I go to "/organization"
        Then I should see "Department of Health"
        When I view the "department-of-health" organisation API "not including" users
        Then I should see an element with xpath "//*[contains(string(), '"success": true,') and contains(string(), '"name": "department-of-health"')]"
