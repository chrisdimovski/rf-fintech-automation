*** Settings ***
Library    RequestsLibrary

*** Keywords ***
Create API Session
    [Arguments]    ${alias}    ${base}    ${timeout}=15
    ${exists}=    Session Exists    ${alias}
    IF    not ${exists}
        Create Session    ${alias}    ${base}    timeout=${timeout}
    END

POST JSON
    [Arguments]    ${alias}    ${path}    ${headers}    ${body}    ${expected_status}=any
    ${resp}=    POST On Session    ${alias}    ${path}    headers=${headers}    json=${body}    expected_status=${expected_status}
    RETURN    ${resp}
