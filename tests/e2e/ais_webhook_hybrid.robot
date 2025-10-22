*** Settings ***
Documentation    AIS with Webhook Kick (Hybrid) – polling plus sandbox webhook follow-up (requires PLAID_WEBHOOK_URL).
Resource    ../unit/resources/unit_common.robot
Library     JSONLibrary
Library     OperatingSystem
Library     BuiltIn

*** Test Cases ***
AIS with Webhook Kick (Hybrid)
    [Documentation]    Poll core endpoints, fire a sandbox webhook, then run a follow-up sync.
    Given an AIS sandbox item exists
    When I poll accounts balances and transactions
    Then all polling calls should succeed
    Then I store the latest transactions cursor
    Given webhook support is configured
    When I fire a sandbox transactions webhook
    Then I should follow up with a transactions sync

*** Keywords ***
Given an AIS sandbox item exists
    ${_public}    ${access_token}    ${item_id}=    Create Sandbox Item
    Set Test Variable    ${ACCESS_TOKEN}    ${access_token}
    Set Test Variable    ${ITEM_ID}        ${item_id}

When I poll accounts balances and transactions
    ${accounts}=    Accounts Get
    ${balances}=    Balances Get
    ${transactions}=    Transactions Sync
    Set Test Variable    ${ACCOUNTS_RESPONSE}      ${accounts}
    Set Test Variable    ${BALANCES_RESPONSE}      ${balances}
    Set Test Variable    ${TRANSACTIONS_RESPONSE}  ${transactions}

Then all polling calls should succeed
    Should Be Equal As Integers    ${ACCOUNTS_RESPONSE.status_code}       200
    Should Be Equal As Integers    ${BALANCES_RESPONSE.status_code}       200
    Should Be Equal As Integers    ${TRANSACTIONS_RESPONSE.status_code}   200

Then I store the latest transactions cursor
    ${json}=    Call Method    ${TRANSACTIONS_RESPONSE}    json
    Set Test Variable    ${LATEST_CURSOR}    ${json["next_cursor"]}

Given webhook support is configured
    ${webhook}=    Get Environment Variable    PLAID_WEBHOOK_URL    ${EMPTY}
    Run Keyword If    '${webhook}' == ''    Skip    Configure PLAID_WEBHOOK_URL to exercise webhook tests.

When I fire a sandbox transactions webhook
    ${resp}=    Fire Sandbox Transactions Webhook    ${ACCESS_TOKEN}
    Set Test Variable    ${WEBHOOK_RESPONSE}    ${resp}

Then I should follow up with a transactions sync
    Should Be Equal As Integers    ${WEBHOOK_RESPONSE.status_code}    200
    ${resp}=    Transactions Sync    ${ACCESS_TOKEN}    ${LATEST_CURSOR}
    Should Be Equal As Integers    ${resp.status_code}    200
