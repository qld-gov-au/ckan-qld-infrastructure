@data_usability_rating
@OpenData
@multi_plugin
Feature: Data usability rating

    Scenario Outline: As a publisher, when I create a resource with an open license, I can verify the openness score is correct
        Given "TestOrgEditor" as the persona
        When I log in
        And I create a dataset and resource with key-value parameters "license=other-open" and "format=<Format>::upload=<Filename>"
        And I press the element with xpath "//ol[contains(@class, 'breadcrumb')]//a[starts-with(@href, '/dataset/')]"
        And I reload page every 3 seconds until I see an element with xpath "//div[contains(@class, 'qa') and contains(@class, 'openness-')]" but not more than 10 times
        Then I should see data usability rating <Score>
        When I press "Test Resource"
        Then I should see data usability rating <Score>

        Examples: Formats
            | Format | Filename           | Score |
            | HTML   | html_resource.html | 0     |
            | TXT    | txt_resource.txt   | 1     |
            | XLS    | xls_resource.xls   | 2     |
            | CSV    | csv_resource.csv   | 3     |
            | JSON   | json_resource.json | 3     |
            | RDF    | rdf_resource.rdf   | 4     |

    Scenario: As a publisher, when I create an open resource with a matching schema, I can verify the score is upgraded from 3 to 4
        Given "TestOrgEditor" as the persona
        When I log in
        And I create a dataset and resource with key-value parameters "license=other-open" and "format=CSV::upload=test_game_data.csv::schema=default"
        And I press the element with xpath "//ol[contains(@class, 'breadcrumb')]//a[starts-with(@href, '/dataset/')]"
        And I reload page every 3 seconds until I see an element with xpath "//div[contains(@class, 'qa') and contains(@class, 'openness-4')]" but not more than 10 times
        Then I should not see an element with xpath "//div[contains(@class, 'openness-3')]"
        And I should see an element with xpath "//div[contains(@class, 'openness-4')]"
        When I take a debugging screenshot
        And I press "Test Resource"
        And I reload page every 3 seconds until I see an element with xpath "//div[contains(@class, 'qa') and contains(@class, 'openness-4')]" but not more than 10 times
        Then I should not see an element with xpath "//div[contains(@class, 'openness-3')]"
