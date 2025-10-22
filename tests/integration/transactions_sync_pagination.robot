*** Settings ***
Documentation    Transactions Sync Pagination – walk Plaid sync cursors and ensure no duplicates.
Resource    ../../resources/services/plaid.robot
Library     JSONLibrary
Library     Collections

*** Variables ***
${PAGE_SIZE}    2

*** Test Cases ***
Transactions Sync Pagination
    [Documentation]    Follow /transactions/sync pages until has_more is false, ensuring no duplicate IDs.
    Given a sandbox access token for pagination
    When I walk transactions sync pagination
    Then pagination should gather unique transactions

*** Keywords ***
Given a sandbox access token for pagination
    ${public_token}=    Create Sandbox Public Token
    ${access_token}    ${item_id}=    Exchange Public Token For Access Token    ${public_token}
    Set Test Variable    ${ACCESS_TOKEN}    ${access_token}

When I walk transactions sync pagination
    Fire Sandbox Transactions Webhook    ${ACCESS_TOKEN}
    ${all_ids}=    Create List
    ${cursor}=     Set Variable    ${None}
    ${final_cursor}=    Set Variable    ${None}
    FOR    ${index}    IN RANGE    0    20
        ${resp}=    Transactions Sync    ${ACCESS_TOKEN}    ${cursor}    ${PAGE_SIZE}
        ${status}=   Set Variable    ${resp.status_code}
        IF    ${status} != 200
            ${error_json}=    Call Method    ${resp}    json
            ${error_code}=    Set Variable    ${error_json.get("error_code")}
            IF    '${error_code}' == 'PRODUCT_NOT_READY'
                Log    Transactions sync not ready yet (PRODUCT_NOT_READY); retrying...    level=INFO
                Sleep    3s
                Continue For Loop
            END
            IF    '${error_code}' == 'TRANSACTIONS_SYNC_MUTATION_DURING_PAGINATION'
                Log    Sync mutation detected during pagination; restarting from initial cursor.    level=INFO
                ${cursor}=        Set Variable    ${None}
                ${all_ids}=       Create List
                ${final_cursor}=  Set Variable    ${None}
                Sleep    2s
                Continue For Loop
            END
            Fail    Unexpected error from transactions/sync: ${error_json}
        END
        ${json}=    Call Method    ${resp}    json
        FOR    ${t}    IN    @{json["added"]}
            ${id}=    Set Variable    ${t["transaction_id"]}
            Should Not Contain    ${all_ids}    ${id}
            Append To List    ${all_ids}    ${id}
        END
        ${cursor}=    Set Variable    ${json["next_cursor"]}
        ${has_more}=  Set Variable    ${json.get("has_more", False)}
        ${added_count}=    Get Length    ${json["added"]}
        IF    ${added_count} == 0 and not ${has_more}
            Log    Transactions sync returned no new data; waiting for sandbox to populate.    level=INFO
            Sleep    3s
            Continue For Loop
        END
        IF    not ${has_more}
            ${final_cursor}=    Set Variable    ${cursor}
            Exit For Loop
        END
    END
    Set Test Variable    ${COLLECTED_TRANSACTION_IDS}    ${all_ids}
    ${final_cursor}=    Set Variable If    '${final_cursor}' == '${None}'    ${cursor}    ${final_cursor}
    Set Test Variable    ${FINAL_CURSOR}    ${final_cursor}

Then pagination should gather unique transactions
    ${count}=    Get Length    ${COLLECTED_TRANSACTION_IDS}
    Should Be True    ${count} > 0
    ${unique_count}=    Evaluate    len(set(${COLLECTED_TRANSACTION_IDS}))
    Should Be Equal As Integers    ${unique_count}    ${count}
    Should Not Be Empty    ${FINAL_CURSOR}
