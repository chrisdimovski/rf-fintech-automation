*** Settings ***
Library    Browser

*** Keywords ***
Cart Should Contain Items
    [Documentation]    Assert that at least one item exists in the cart summary table.
    Wait For Elements State    css=.cart_info >> nth=0    visible
    Wait Until Keyword Succeeds    20 s    1 s    Cart Rows Should Exist

Cart Rows Should Exist
    ${row_count}=    Get Element Count    css=.cart_info
    Should Be True    ${row_count} > 0
    Get Element    css=.cart_info .cart_description
