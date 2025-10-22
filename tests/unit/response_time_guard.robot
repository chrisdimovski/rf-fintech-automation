*** Settings ***
Documentation    Response Time Guard – ensures /accounts/get completes within the SLA threshold.
Resource    resources/unit_common.robot

*** Variables ***
${MAX_RESPONSE_SECONDS}    2.0

*** Test Cases ***
Response Time Guard (Contract)
    [Documentation]    Measure /accounts/get round-trip time and assert it is below ${MAX_RESPONSE_SECONDS} seconds.
    Given a sandbox access token
    When I time the accounts request
    Then the elapsed time should remain under the SLA

*** Keywords ***
Given a sandbox access token
    ${_public}    ${access_token}    ${item_id}=    Create Sandbox Item
    Set Test Variable    ${ACCESS_TOKEN}    ${access_token}

When I time the accounts request
    ${start}=    Get Time    epoch
    ${resp}=    Accounts Get
    ${end}=      Get Time    epoch
    Set Test Variable    ${ACCOUNTS_RESPONSE}    ${resp}
    ${start_num}=    Convert To Number    ${start}
    ${end_num}=      Convert To Number    ${end}
    ${elapsed}=      Evaluate    ${end_num} - ${start_num}
    Set Test Variable    ${ELAPSED_SECONDS}    ${elapsed}

Then the elapsed time should remain under the SLA
    Should Be Equal As Integers    ${ACCOUNTS_RESPONSE.status_code}    200
    Should Be True    ${ELAPSED_SECONDS} < ${MAX_RESPONSE_SECONDS}    msg=Accounts call exceeded SLA (${ELAPSED_SECONDS}s)
