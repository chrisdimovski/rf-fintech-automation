*** Settings ***
Documentation    Auth: Token Exchange Works – ensures public token exchange yields access_token and item_id.
Resource    resources/unit_common.robot

*** Test Cases ***
Auth: Token Exchange Works
    [Documentation]    Call /sandbox/public_token/create then /item/public_token/exchange and check credentials are returned.
    Given a fresh sandbox public token
    When I exchange the public token for credentials
    Then the sandbox exchange should return credentials

*** Keywords ***
Given a fresh sandbox public token
    ${public_token}=    Create Sandbox Public Token
    Set Test Variable    ${PUBLIC_TOKEN}    ${public_token}

When I exchange the public token for credentials
    ${access_token}    ${item_id}=    Exchange Public Token For Access Token    ${PUBLIC_TOKEN}
    Set Test Variable    ${ACCESS_TOKEN}    ${access_token}
    Set Test Variable    ${ITEM_ID}        ${item_id}

Then the sandbox exchange should return credentials
    Should Not Be Empty    ${ACCESS_TOKEN}
    Should Not Be Empty    ${ITEM_ID}
