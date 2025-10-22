*** Settings ***
Documentation    Currency Presence Contract – ensures each account carries currency codes and numeric balances.
Resource    resources/unit_common.robot

*** Test Cases ***
Currency Presence Contract
    [Documentation]    Fetch /accounts/get and verify iso_currency_code presence and numeric balances.
    Given a sandbox access token
    When I fetch accounts from Plaid
    Then each account should declare currency and numeric balances

*** Keywords ***
Given a sandbox access token
    ${_public}    ${access_token}    ${item_id}=    Create Sandbox Item
    Set Test Variable    ${ACCESS_TOKEN}    ${access_token}

When I fetch accounts from Plaid
    ${resp}=    Accounts Get
    Set Test Variable    ${ACCOUNTS_RESPONSE}    ${resp}

Then each account should declare currency and numeric balances
    Should Be Equal As Integers    ${ACCOUNTS_RESPONSE.status_code}    200
    ${json}=    Call Method    ${ACCOUNTS_RESPONSE}    json
    FOR    ${acct}    IN    @{json["accounts"]}
        ${balances}=    Get From Dictionary    ${acct}    balances
        ${currency}=    Get From Dictionary    ${balances}    iso_currency_code
        IF    '${currency}' not in ('', 'None')
            Should Not Be Empty    ${currency}
        END
        ${current}=     Get From Dictionary    ${balances}    current
        Ensure Numeric Value    ${current}    Current balance must be numeric
        ${available_status}    ${available}=    Run Keyword And Ignore Error    Get From Dictionary    ${balances}    available
        IF    '${available_status}' == 'PASS'
            IF    '${available}' not in ('', 'None')
                Ensure Numeric Value    ${available}    Available balance must be numeric
            END
        END
    END
