*** Settings ***
Library    Browser

*** Variables ***
${BASE_URL}       https://www.automationexercise.com
${BROWSER}        chromium
${HEADLESS_ENV}   %{PLAYWRIGHT_HEADLESS=False}

*** Keywords ***
Open Browser To Automation Exercise
    [Documentation]    Launch Playwright browser and open the Automation Exercise home page.
    ${headless}=    Evaluate    '${HEADLESS_ENV}'.lower() in ("true", "1", "yes")
    ${browser}=    New Browser    ${BROWSER}    headless=${headless}
    Set Suite Variable    ${browser}
    New Context
    New Page    ${BASE_URL}

Go To Home Page
    [Documentation]    Navigate to the Automation Exercise home page.
    Go To    ${BASE_URL}

Close Automation Browser
    [Documentation]    Close all Playwright browser instances.
    Browser.Close Browser

Url Should Contain
    [Arguments]    ${fragment}
    ${url}=    Get Url
    Should Contain    ${url}    ${fragment}

Wait For Url To Contain
    [Arguments]    ${fragment}
    Wait Until Keyword Succeeds    10 s    500 ms    Url Should Contain    ${fragment}

Scroll Page To Bottom
    [Documentation]    Scroll the current page to the bottom.
    Press Keys    css=body    End

Scroll Element Into View
    [Arguments]    ${selector}
    [Documentation]    Scroll the specified element into view.
    Evaluate Javascript    ${selector}    (element) => element.scrollIntoView({behavior: 'instant', block: 'center', inline: 'center'})
