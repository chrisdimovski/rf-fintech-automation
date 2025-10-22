*** Settings ***
Library    Browser

*** Keywords ***
Subscribe With Email
    [Arguments]    ${email}
    [Documentation]    Submit the footer newsletter form.
    Scroll Element Into View    css=#susbscribe_email
    Fill Text    css=#susbscribe_email    ${email}
    Click    css=#subscribe

Should See Subscription Success
    [Documentation]    Verify the subscription success banner is displayed.
    Wait For Elements State    css=.alert-success    visible
    ${message}=    Get Text    css=.alert-success
    Should Contain    ${message}    You have been successfully subscribed!
