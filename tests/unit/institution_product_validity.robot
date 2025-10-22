*** Settings ***
Documentation    Institution/Product Validity – ensures Plaid returns INVALID_FIELD for bad institution/product combos.
Resource    resources/unit_common.robot

*** Test Cases ***
Institution/Product Validity
    [Documentation]    Request a public token with an invalid institution and expect INVALID_FIELD style errors.
    Given a sandbox request with an invalid institution
    When I attempt to create a sandbox public token
    Then Plaid should respond with an invalid field error

*** Keywords ***
Given a sandbox request with an invalid institution
    Create Plaid Session
    ${headers}=    _Plaid Headers
    ${products}=   Create List    transactions
    ${payload}=    _Plaid Auth Merge    institution_id=ins_fake999    initial_products=${products}
    Set Test Variable    ${INVALID_PAYLOAD}    ${payload}
    Set Test Variable    ${HEADERS}           ${headers}

When I attempt to create a sandbox public token
    ${resp}=    POST JSON    plaid    /sandbox/public_token/create    ${HEADERS}    ${INVALID_PAYLOAD}
    Set Test Variable    ${INVALID_FIELD_RESPONSE}    ${resp}

Then Plaid should respond with an invalid field error
    Should Be Equal As Integers    ${INVALID_FIELD_RESPONSE.status_code}    400
    ${json}=    Call Method    ${INVALID_FIELD_RESPONSE}    json
    Should Be Equal    ${json["error_type"]}    INVALID_INPUT
    Should Be Equal    ${json["error_code"]}    INVALID_INSTITUTION
