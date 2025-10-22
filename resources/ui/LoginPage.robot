*** Settings ***
Library    Browser

*** Keywords ***
Attempt Login With Credentials
    [Arguments]    ${email}    ${password}
    [Documentation]    Submit the login form with the given credentials.
    Fill Text    css=input[data-qa='login-email']    ${email}
    Fill Text    css=input[data-qa='login-password']    ${password}
    Click    css=button[data-qa='login-button']

Should See Invalid Login Error
    [Documentation]    Validate the invalid login banner appears.
    Wait For Elements State    css=.login-form p    visible
    ${message}=    Get Text    css=.login-form p
    Should Be Equal    ${message}    Your email or password is incorrect!
