*** Settings ***
Documentation    Resilience: Retry Budget – ensure client succeeds within retry allowance.
Resource    ../unit/resources/unit_common.robot

*** Variables ***
${RETRY_ATTEMPTS}    3
${RETRY_INTERVAL}    1s

*** Test Cases ***
Resilience: Retry Budget
    [Documentation]    Call /accounts/get with a small retry budget to simulate transient recovery.
    Given an AIS sandbox item exists
    When I call accounts with a retry budget

*** Keywords ***
Given an AIS sandbox item exists
    ${_public}    ${access_token}    ${item_id}=    Create Sandbox Item
    Set Test Variable    ${ACCESS_TOKEN}    ${access_token}

When I call accounts with a retry budget
    Wait Until Keyword Succeeds    ${RETRY_ATTEMPTS} times    ${RETRY_INTERVAL}    Accounts Call Should Succeed

Accounts Call Should Succeed
    ${resp}=    Accounts Get
    Should Be Equal As Integers    ${resp.status_code}    200
