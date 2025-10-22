*** Settings ***
Documentation    Accounts Schema Contract – validates /accounts/get against stored schema.
Resource    resources/unit_common.robot

*** Test Cases ***
Accounts Schema Contract
    [Documentation]    Create a sandbox item, call /accounts/get, and assert the payload matches plaid_accounts.schema.json.
    Given a sandbox access token
    When I fetch accounts from Plaid
    Then the accounts payload should match the schema

*** Keywords ***
Given a sandbox access token
    ${_public}    ${access_token}    ${item_id}=    Create Sandbox Item
    Set Test Variable    ${ACCESS_TOKEN}    ${access_token}
    Set Test Variable    ${ITEM_ID}        ${item_id}

When I fetch accounts from Plaid
    ${resp}=    Accounts Get
    Set Test Variable    ${ACCOUNTS_RESPONSE}    ${resp}

Then the accounts payload should match the schema
    Should Be Equal As Integers    ${ACCOUNTS_RESPONSE.status_code}    200
    ${json}=    Call Method    ${ACCOUNTS_RESPONSE}    json
    ${schema}=  Load Json From File      ${CURDIR}/../../resources/schemas/plaid_accounts.schema.json
    Validate Json By Schema    ${json}    ${schema}
