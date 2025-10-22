*** Settings ***
Documentation    Invalid Access Token Error Contract – ensures Plaid returns structured errors for bogus tokens.
Resource    resources/unit_common.robot

*** Test Cases ***
Invalid Access Token Error Contract
    [Documentation]    Call /accounts/get with a bogus token and verify an INVALID_ACCESS_TOKEN response.
    Given a bogus sandbox access token
    When I call accounts get with that token
    Then Plaid should return INVALID_ACCESS_TOKEN

*** Keywords ***
Given a bogus sandbox access token
    Set Test Variable    ${BAD_TOKEN}    bad_access_token_123

When I call accounts get with that token
    ${resp}=    Accounts Get    ${BAD_TOKEN}
    Set Test Variable    ${ERROR_RESPONSE}    ${resp}

Then Plaid should return INVALID_ACCESS_TOKEN
    Should Be Equal As Integers    ${ERROR_RESPONSE.status_code}    400
    ${json}=    Call Method    ${ERROR_RESPONSE}    json
    Should Be Equal    ${json["error_code"]}    INVALID_ACCESS_TOKEN
    Should Be Equal    ${json["error_type"]}    INVALID_INPUT
