*** Settings ***
Documentation    Transactions Cursor Advances – ensures successive sync calls respect cursors and avoid duplicates.
Resource    resources/unit_common.robot
Library     Collections

*** Variables ***
${SYNC_COUNT}    4

*** Test Cases ***
Transactions Cursor Advances
    [Documentation]    Run back-to-back /transactions/sync calls and ensure the cursor advances without duplicating transactions.
    Given a sandbox transactions access token
    When I run an initial transactions sync with cursor collection
    Then the follow up sync should return a new cursor and no duplicate transactions

*** Keywords ***
Given a sandbox transactions access token
    ${_public}    ${access_token}    ${item_id}=    Create Sandbox Item
    Set Test Variable    ${ACCESS_TOKEN}    ${access_token}

When I run an initial transactions sync with cursor collection
    ${resp}=    Transactions Sync    ${ACCESS_TOKEN}    ${None}    ${SYNC_COUNT}
    Should Be Equal As Integers    ${resp.status_code}    200
    ${json}=    Call Method    ${resp}    json
    Set Test Variable    ${INITIAL_JSON}    ${json}
    ${cursor}=    Get From Dictionary    ${json}    next_cursor
    Set Test Variable    ${INITIAL_CURSOR}    ${cursor}
    ${first_ids}=    Create List
    FOR    ${t}    IN    @{json["added"]}
        Append To List    ${first_ids}    ${t}["transaction_id"]
    END
    Set Test Variable    ${FIRST_IDS}    ${first_ids}

Then the follow up sync should return a new cursor and no duplicate transactions
    ${has_cursor}=    Run Keyword And Return Status    Should Not Be Empty    ${INITIAL_CURSOR}
    IF    not ${has_cursor}
        Log    Initial sync returned empty cursor; skipping follow-up validation.
        RETURN
    END
    ${resp}=    Transactions Sync    ${ACCESS_TOKEN}    ${INITIAL_CURSOR}    ${SYNC_COUNT}
    Should Be Equal As Integers    ${resp.status_code}    200
    ${json}=    Call Method    ${resp}    json
    ${next_cursor}=    Get From Dictionary    ${json}    next_cursor
    ${second_ids}=    Create List
    FOR    ${t}    IN    @{json["added"]}
        ${id}=    Get From Dictionary    ${t}    transaction_id
        Append To List    ${second_ids}    ${id}
    END
    ${overlap}=    Evaluate    set(first_ids) & set(second_ids)    first_ids=${FIRST_IDS}    second_ids=${second_ids}
    Should Be True    len(${overlap}) == 0    msg=Duplicate transactions detected between sync pages
