*** Settings ***
Documentation    Transactions Sync Contract – validates initial /transactions/sync payload.
Resource    resources/unit_common.robot

*** Test Cases ***
Transactions Sync Contract (Initial)
    [Documentation]    Perform an initial transactions sync and validate schema compliance.
    Given a sandbox transactions access token
    When I perform an initial transactions sync
    Then the sync payload should match the schema

*** Keywords ***
Given a sandbox transactions access token
    ${_public}    ${access_token}    ${item_id}=    Create Sandbox Item
    Set Test Variable    ${ACCESS_TOKEN}    ${access_token}

When I perform an initial transactions sync
    ${resp}=    Transactions Sync    ${ACCESS_TOKEN}
    Set Test Variable    ${SYNC_RESPONSE}    ${resp}

Then the sync payload should match the schema
    Should Be Equal As Integers    ${SYNC_RESPONSE.status_code}    200
    ${json}=    Call Method    ${SYNC_RESPONSE}    json
    ${schema}=  Load Json From File      ${CURDIR}/../../resources/schemas/plaid_transactions_sync.schema.json
    Validate Json By Schema    ${json}    ${schema}
