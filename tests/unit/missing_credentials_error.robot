*** Settings ***
Documentation    Missing Credentials Error Contract – ensures Plaid rejects requests without client credentials.
Resource    resources/unit_common.robot

*** Test Cases ***
Missing Credentials Error Contract
    [Documentation]    Clear client_id/secret and expect a structured 400 from /sandbox/public_token/create.
    [Teardown]    Restore Plaid Credentials    ${ORIG_CLIENT_ID}    ${ORIG_SECRET}
    Given Plaid credentials are cleared for this test
    When I call sandbox public token create without credentials
    Then Plaid should reject the request due to missing credentials

*** Keywords ***
Given Plaid credentials are cleared for this test
    ${cid}    ${sec}=    Capture Plaid Credentials Snapshot
    Set Test Variable    ${ORIG_CLIENT_ID}    ${cid}
    Set Test Variable    ${ORIG_SECRET}    ${sec}
    Set Plaid Credentials    ${EMPTY}    ${EMPTY}

When I call sandbox public token create without credentials
    Create Plaid Session
    ${headers}=    _Plaid Headers
    ${payload}=    Create Dictionary    institution_id=ins_109508
    ${products}=   Create List    transactions
    Set To Dictionary    ${payload}    initial_products=${products}
    Set To Dictionary    ${payload}    client_id=${EMPTY}
    Set To Dictionary    ${payload}    secret=${EMPTY}
    ${resp}=       POST JSON    plaid    /sandbox/public_token/create    ${headers}    ${payload}
    Set Test Variable    ${MISSING_CREDS_RESPONSE}    ${resp}

Then Plaid should reject the request due to missing credentials
    Should Be Equal As Integers    ${MISSING_CREDS_RESPONSE.status_code}    400
    ${json}=    Call Method    ${MISSING_CREDS_RESPONSE}    json
    Should Contain    ${json}    error_code
    Should Be Equal    ${json["error_type"]}    INVALID_REQUEST
