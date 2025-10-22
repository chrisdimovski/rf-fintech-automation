*** Settings ***
Documentation    Integration flow that walks through accounts and balances endpoints for a shared sandbox item.
Resource    ../../resources/services/plaid.robot
Library     JSONLibrary
Library     Collections
Suite Setup    Prepare Integration Item

*** Keywords ***
Prepare Integration Item
    [Documentation]    Create one sandbox item and share its access token for integration scenarios.
    ${pt}=    Create Sandbox Public Token
    ${access}    ${item}=    Exchange Public Token For Access Token    ${pt}
    Set Suite Variable    ${ACCESS_TOKEN}    ${access}
    Set Suite Variable    ${ITEM_ID}        ${item}

Given a sandbox access token for integration
    Should Not Be Empty    ${ACCESS_TOKEN}

When I fetch accounts and balances sequentially
    ${accounts}=    Accounts Get
    ${balances}=    Balances Get
    Set Test Variable    ${ACCOUNTS_RESPONSE}    ${accounts}
    Set Test Variable    ${BALANCES_RESPONSE}     ${balances}

Then both calls should succeed
    Should Be Equal As Integers    ${ACCOUNTS_RESPONSE.status_code}    200
    Should Be Equal As Integers    ${BALANCES_RESPONSE.status_code}    200

Then account and balance currencies should align
    ${accounts_json}=    Call Method    ${ACCOUNTS_RESPONSE}    json
    ${balances_json}=    Call Method    ${BALANCES_RESPONSE}    json
    ${currency_map}=    Create Dictionary
    FOR    ${acct}    IN    @{accounts_json["accounts"]}
        ${currency}=    Get Account Currency    ${acct}
        Should Not Be Empty    ${currency}
        Set To Dictionary    ${currency_map}    ${acct["account_id"]}=${currency}
    END
    FOR    ${acct}    IN    @{balances_json["accounts"]}
        ${account_id}=    Set Variable    ${acct["account_id"]}
        Dictionary Should Contain Key    ${currency_map}    ${account_id}
        ${currency}=    Get From Dictionary    ${currency_map}    ${account_id}
        ${current}=    Set Variable    ${acct["balances"]["current"]}
        ${is_number}=    Evaluate    isinstance(${current}, (int, float))
        Should Be True    ${is_number}
        ${available}=    Set Variable    ${acct["balances"].get("available")}
        IF    ${available} != ${None}
            Validate Optional Balance    ${available}
        END
        ${balance_currency}=    Get Account Currency    ${acct}
        Should Be Equal    ${balance_currency}    ${currency}
    END

Validate Optional Balance
    [Arguments]    ${value}
    ${is_number}=    Evaluate    isinstance(${value}, (int, float))
    Should Be True    ${is_number}

Get Account Currency
    [Arguments]    ${account}
    ${currency}=    Set Variable    ${account.get("iso_currency_code")}
    IF    '${currency}' == 'None' or '${currency}' == ''
        Dictionary Should Contain Key    ${account}    balances
        ${balances}=    Get From Dictionary    ${account}    balances
        Dictionary Should Contain Key    ${balances}    iso_currency_code
        ${currency}=    Get From Dictionary    ${balances}    iso_currency_code
    END
    RETURN    ${currency}

*** Test Cases ***
Accounts → Balances Flow
    [Documentation]    Create an item, call /accounts/get then /accounts/balance/get, and ensure currencies and balances are consistent.
    Given a sandbox access token for integration
    When I fetch accounts and balances sequentially
    Then both calls should succeed
    Then account and balance currencies should align
