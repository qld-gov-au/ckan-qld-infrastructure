@smoke
Feature: Homepage

    @homepage
    @unauthenticated
    Scenario: Smoke test to ensure Homepage is accessible
        Given "Unauthenticated" as the persona
        When I go to homepage
        And I should see an element with xpath "//meta[@name='DCTERMS.publisher' and @content='corporateName=The State of Queensland; jurisdiction=Queensland' and @scheme='AGLSTERMS.AglsAgent']"
        And I should see an element with xpath "//meta[@name='DCTERMS.jurisdiction' and @content='Queensland' and @scheme='AGLSTERMS.AglsJuri']"
        And I should see an element with xpath "//meta[@name='DCTERMS.type' and @content='Text' and @scheme='DCTERMS.DCMIType']"

    @Publications
    Scenario: 'Publish in the Gazettes' link is visible
        Given "Unauthenticated" as the persona
        When I go to homepage
        Then I should see an element with xpath "//a[@href='https://www.forgov.qld.gov.au/information-and-communication-technology/communication-and-publishing/website-and-digital-publishing/queensland-government-gazette/publish-in-the-gazette' and string()='Publish in the Gazettes']"
