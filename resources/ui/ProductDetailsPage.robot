*** Settings ***
Library    Browser

*** Keywords ***
Add Product To Cart And View Cart
    [Documentation]    Add the currently viewed product to the cart and open the cart page.
    Click    xpath=//button[contains(., 'Add to cart')]
    Wait For Elements State    id=cartModal    visible
    Click    xpath=//div[@id='cartModal']//a[contains(., 'View Cart')]
    Wait For Url To Contain    /view_cart
