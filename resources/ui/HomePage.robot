*** Settings ***
Library    Browser
Resource   Browser.robot

*** Keywords ***
Home Page Should Be Visible
    [Documentation]    Assert basic elements on the Automation Exercise home page.
    ${url}=    Get Url
    Should Contain    ${url}    ${BASE_URL}
    Wait For Elements State    css=.carousel-inner >> nth=0    visible

Open Products Page
    [Documentation]    Navigate from the home page to the Products catalogue.
    Click    xpath=//a[@href='/products']

Open Signup Login Page
    [Documentation]    Navigate from the home page to the Signup/Login page.
    Click    xpath=//a[@href='/login']

Scroll To Footer
    [Documentation]    Scroll to footer section for subscription interactions.
    Scroll Page To Bottom
