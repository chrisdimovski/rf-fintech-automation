*** Settings ***
Resource    ../../../resources/services/plaid.robot
Library     JSONLibrary
Library     JSONSchemaLibrary
Library     Collections
Library     OperatingSystem
Library     BuiltIn

*** Keywords ***
Create Sandbox Item
    ${public_token}=    Create Sandbox Public Token
    ${access_token}    ${item_id}=    Exchange Public Token For Access Token    ${public_token}
    RETURN    ${public_token}    ${access_token}    ${item_id}

Ensure Numeric Value
    [Arguments]    ${value}    ${message}=Expected numeric value
    ${status}    ${converted}=    Run Keyword And Ignore Error    Convert To Number    ${value}
    IF    '${status}' != 'PASS'
        Fail    ${message} (value=${value})
    END

Capture Plaid Credentials Snapshot
    ${cid}=    Get Environment Variable    PLAID_CLIENT_ID    ${EMPTY}
    ${sec}=    Get Environment Variable    PLAID_SECRET       ${EMPTY}
    RETURN    ${cid}    ${sec}

Restore Plaid Credentials
    [Arguments]    ${client_id}    ${secret}
    Set Environment Variable    PLAID_CLIENT_ID    ${client_id}
    Set Environment Variable    PLAID_SECRET       ${secret}

Set Plaid Credentials
    [Arguments]    ${client_id}    ${secret}
    Set Environment Variable    PLAID_CLIENT_ID    ${client_id}
    Set Environment Variable    PLAID_SECRET       ${secret}
