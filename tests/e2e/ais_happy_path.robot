*** Settings ***
Documentation    AIS Happy Path (Polling) – end-to-end polling of accounts, balances, and transactions.
Resource    ../unit/resources/unit_common.robot
Library     JSONLibrary

*** Test Cases ***
AIS Happy Path (Polling)
    [Documentation]    Create a sandbox item and poll accounts, balances, and transactions successfully.
    Given an AIS sandbox item exists
    When I poll accounts balances and transactions
    Then all polling calls should succeed
    Then I store the latest transactions cursor

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
