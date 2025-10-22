*** Settings ***
Documentation    Negative Auth Integration – ensure tampered tokens yield auth errors.
Resource    ../../resources/services/plaid.robot
Library     JSONLibrary
Library     String

*** Test Cases ***
Negative Auth Integration
    [Documentation]    Mutate an access token and confirm Plaid rejects the request with INVALID_ACCESS_TOKEN.
    Given a sandbox access token for negative testing
    When I tamper with the access token and call accounts
    Then Plaid should respond with an invalid authentication error

*** Keywords ***
Given a sandbox access token for negative testing
    ${public_token}=    Create Sandbox Public Token
    ${access_token}    ${item_id}=    Exchange Public Token For Access Token    ${public_token}
    Set Test Variable    ${ACCESS_TOKEN}    ${access_token}

When I tamper with the access token and call accounts
    ${base}=        Get Substring    ${ACCESS_TOKEN}    0    -4
    ${mutated}=     Catenate    SEPARATOR=    ${base}    ABCD
    ${resp}=       Accounts Get    ${mutated}
    Set Test Variable    ${NEGATIVE_RESPONSE}    ${resp}

Then Plaid should respond with an invalid authentication error
    Should Be Equal As Integers    ${NEGATIVE_RESPONSE.status_code}    400
    ${json}=    Call Method    ${NEGATIVE_RESPONSE}    json
    Should Be Equal    ${json["error_code"]}    INVALID_ACCESS_TOKEN
