*** Settings ***
Documentation    Webhook Dedupe – placeholder for webhook idempotency verification once receiver is in place.
Resource    ../../resources/services/plaid.robot
Library     OperatingSystem
Library     BuiltIn

*** Test Cases ***
Webhook Dedupe
    [Documentation]    Fire duplicate sandbox webhooks; test is skipped until receiver idempotency checks are implemented.
    Given webhook support is configured for dedupe
    When I fire duplicate sandbox webhooks
    Then webhook dedupe assertions remain pending

*** Keywords ***
Given webhook support is configured for dedupe
    ${webhook}=    Get Environment Variable    PLAID_WEBHOOK_URL    ${EMPTY}
    Run Keyword If    '${webhook}' == ''    Skip    Configure PLAID_WEBHOOK_URL to exercise webhook tests.
    ${public_token}=    Create Sandbox Public Token
    ${access_token}    ${item_id}=    Exchange Public Token For Access Token    ${public_token}
    Set Test Variable    ${ACCESS_TOKEN}    ${access_token}

When I fire duplicate sandbox webhooks
    ${first}=    Fire Sandbox Transactions Webhook    ${ACCESS_TOKEN}
    ${second}=   Fire Sandbox Transactions Webhook    ${ACCESS_TOKEN}
    Set Test Variable    ${FIRST_WEBHOOK_RESPONSE}    ${first}
    Set Test Variable    ${SECOND_WEBHOOK_RESPONSE}   ${second}

Then webhook dedupe assertions remain pending
    Should Be Equal As Integers    ${FIRST_WEBHOOK_RESPONSE.status_code}    200
    Should Be Equal As Integers    ${SECOND_WEBHOOK_RESPONSE.status_code}   200
    Skip    Implement receiver idempotency verification before enabling this scenario.
