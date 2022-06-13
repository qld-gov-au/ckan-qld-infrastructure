@smoke
Feature: Homepage

    @homepage
    @unauthenticated
    Scenario: Smoke test to ensure Homepage is accessible
        Given "Unauthenticated" as the persona
        When I go to homepage
        Then I take a screenshot
        And I should see an element with xpath "//meta[@name='DCTERMS.publisher' and @content='corporateName=The State of Queensland; jurisdiction=Queensland' and @scheme='AGLSTERMS.AglsAgent']"
        And I should see an element with xpath "//meta[@name='DCTERMS.jurisdiction' and @content='Queensland' and @scheme='AGLSTERMS.AglsJuri']"
        And I should see an element with xpath "//meta[@name='DCTERMS.type' and @content='Text' and @scheme='DCTERMS.DCMIType']"
