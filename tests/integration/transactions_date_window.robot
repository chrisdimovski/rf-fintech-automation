*** Settings ***
Documentation    Transactions Date Window Filter – ensure date range filtering works within expected window.
Resource    ../../resources/services/plaid.robot
Library     JSONLibrary

*** Variables ***
${WINDOW_DAYS}    30

*** Test Cases ***
Transactions Date Window Filter
    [Documentation]    Request a recent window via /transactions/get and assert all transactions fall within it.
    Given a sandbox access token for date window testing
    When I request transactions within the recent window
    Then all dates should fall inside the window

*** Keywords ***
Given a sandbox access token for date window testing
    ${public_token}=    Create Sandbox Public Token
    ${access_token}    ${item_id}=    Exchange Public Token For Access Token    ${public_token}
    Set Test Variable    ${ACCESS_TOKEN}    ${access_token}

When I request transactions within the recent window
    Create Plaid Session
    ${start}=    Evaluate    (datetime.datetime.utcnow() - datetime.timedelta(days=${WINDOW_DAYS})).date().isoformat()    modules=datetime
    ${end}=      Evaluate    datetime.datetime.utcnow().date().isoformat()    modules=datetime
    ${headers}=  _Plaid Headers
    ${payload}=  _Plaid Auth Merge    access_token=${ACCESS_TOKEN}    start_date=${start}    end_date=${end}
    Fire Sandbox Transactions Webhook    ${ACCESS_TOKEN}
    ${resp}=    Set Variable    ${None}
    FOR    ${attempt}    IN RANGE    0    10
        ${resp}=     POST JSON    plaid    /transactions/get    ${headers}    ${payload}
        ${status}=    Set Variable    ${resp.status_code}
        IF    ${status} == 200
            ${json}=    Call Method    ${resp}    json
            Set Test Variable    ${WINDOW_JSON}    ${json}
            Set Test Variable    ${WINDOW_START}    ${start}
            Set Test Variable    ${WINDOW_END}      ${end}
            Exit For Loop
        END
        Log    Transactions not ready yet (status ${status}); retrying...    level=INFO
        Sleep    3s
    END
    Should Be Equal As Integers    ${resp.status_code}    200

Then all dates should fall inside the window
    ${start}=    Set Variable    ${WINDOW_START}
    ${end}=      Set Variable    ${WINDOW_END}
    FOR    ${tx}    IN    @{WINDOW_JSON["transactions"]}
        ${tx_date}=    Set Variable    ${tx["date"]}
        Should Be True    '${start}' <= '${tx_date}' <= '${end}'    msg=Transaction outside requested window: ${tx}
    END
