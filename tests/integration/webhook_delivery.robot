*** Settings ***
Documentation    Webhook Delivery (Sandbox-Fired) – placeholder scenario requiring a webhook receiver.
Resource    ../../resources/services/plaid.robot
Library     JSONLibrary
Library     OperatingSystem
Library     BuiltIn

*** Test Cases ***
Webhook Delivery (Sandbox-Fired)
    [Documentation]    Fire a sandbox webhook and rely on an external receiver to validate delivery. Skipped if PLAID_WEBHOOK_URL unset.
    Given webhook support is configured
    When I fire a sandbox transactions webhook
    Then manual verification of webhook delivery is required

*** Keywords ***
Given webhook support is configured
    ${webhook}=    Get Environment Variable    PLAID_WEBHOOK_URL    ${EMPTY}
    Run Keyword If    '${webhook}' == ''    Skip    Configure PLAID_WEBHOOK_URL to exercise webhook tests.
    ${public_token}=    Create Sandbox Public Token
    ${access_token}    ${item_id}=    Exchange Public Token For Access Token    ${public_token}
    Set Test Variable    ${ACCESS_TOKEN}    ${access_token}

When I fire a sandbox transactions webhook
    ${resp}=    Fire Sandbox Transactions Webhook    ${ACCESS_TOKEN}
    Set Test Variable    ${WEBHOOK_RESPONSE}    ${resp}

Then manual verification of webhook delivery is required
    Should Be Equal As Integers    ${WEBHOOK_RESPONSE.status_code}    200
    Skip    Configure webhook receiver assertions before enabling this verification.
