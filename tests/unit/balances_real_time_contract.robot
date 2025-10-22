*** Settings ***
Documentation    Balances Real-Time Contract – schema and numeric assertions for /accounts/balance/get.
Resource    resources/unit_common.robot

*** Test Cases ***
Balances Real-Time Contract
    [Documentation]    Call /accounts/balance/get and verify schema plus numeric balance requirements.
    Given a sandbox balances access token
    When I request real-time balances
    Then the balances payload should match the schema
    And each balance field should be numeric when present

*** Keywords ***
Given a sandbox balances access token
    ${_public}    ${access_token}    ${item_id}=    Create Sandbox Item
    Set Test Variable    ${ACCESS_TOKEN}    ${access_token}

When I request real-time balances
    ${resp}=    Balances Get
    Set Test Variable    ${BALANCE_RESPONSE}    ${resp}

Then the balances payload should match the schema
    Should Be Equal As Integers    ${BALANCE_RESPONSE.status_code}    200
    ${json}=    Call Method    ${BALANCE_RESPONSE}    json
    ${schema}=  Load Json From File      ${CURDIR}/../../resources/schemas/plaid_balances.schema.json
    Validate Json By Schema    ${json}    ${schema}

And each balance field should be numeric when present
    ${json}=    Call Method    ${BALANCE_RESPONSE}    json
    FOR    ${acct}    IN    @{json["accounts"]}
        ${balances}=    Get From Dictionary    ${acct}    balances
        ${current}=     Get From Dictionary    ${balances}    current
        Ensure Numeric Value    ${current}    Current balance must be numeric
        ${available}=   Get From Dictionary    ${balances}    available
        IF    '${available}' not in ('', 'None')
            Ensure Numeric Value    ${available}    Available balance must be numeric
        END
    END
