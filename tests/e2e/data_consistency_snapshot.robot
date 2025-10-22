*** Settings ***
Documentation    Data Consistency Snapshot – verify accounts and balances remain internally consistent.
Resource    ../unit/resources/unit_common.robot
Library     JSONLibrary
Library     Collections

*** Test Cases ***
Data Consistency Snapshot
    [Documentation]    Capture accounts and balances snapshots and ensure numeric sanity and account mapping.
    Given an AIS sandbox item exists
    When I capture accounts and balances snapshots
    Then the snapshot should be self-consistent

*** Keywords ***
Given an AIS sandbox item exists
    ${_public}    ${access_token}    ${item_id}=    Create Sandbox Item
    Set Test Variable    ${ACCESS_TOKEN}    ${access_token}

When I capture accounts and balances snapshots
    ${accounts}=    Accounts Get
    ${balances}=    Balances Get
    Set Test Variable    ${SNAPSHOT_ACCOUNTS}    ${accounts}
    Set Test Variable    ${SNAPSHOT_BALANCES}    ${balances}

Then the snapshot should be self-consistent
    Should Be Equal As Integers    ${SNAPSHOT_ACCOUNTS.status_code}    200
    Should Be Equal As Integers    ${SNAPSHOT_BALANCES.status_code}    200
    ${accounts_json}=    Call Method    ${SNAPSHOT_ACCOUNTS}    json
    ${balances_json}=    Call Method    ${SNAPSHOT_BALANCES}    json
    ${balance_map}=    Create Dictionary
    FOR    ${acct}    IN    @{balances_json["accounts"]}
        ${current}=    Set Variable    ${acct["balances"]["current"]}
        Ensure Numeric Value    ${current}    Current balance must be numeric
        Set To Dictionary    ${balance_map}    ${acct["account_id"]}=${current}
    END
    FOR    ${acct}    IN    @{accounts_json["accounts"]}
        ${account_id}=    Set Variable    ${acct["account_id"]}
        Dictionary Should Contain Key    ${balance_map}    ${account_id}
        ${currency}=    Get Account Currency From Snapshot    ${acct}
        Should Not Be Empty    ${currency}
        ${balance}=    Get From Dictionary    ${balance_map}    ${account_id}
        IF    ${balance} != ${None}
            Should Be True    ${balance} >= 0
        END
    END

Get Account Currency From Snapshot
    [Arguments]    ${account}
    ${status}    ${currency}=    Run Keyword And Ignore Error    Get From Dictionary    ${account}    iso_currency_code
    IF    '${status}' != 'PASS'
        Dictionary Should Contain Key    ${account}    balances
        ${balances}=    Get From Dictionary    ${account}    balances
        Dictionary Should Contain Key    ${balances}    iso_currency_code
        ${currency}=    Get From Dictionary    ${balances}    iso_currency_code
    END
    RETURN    ${currency}
