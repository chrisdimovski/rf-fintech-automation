*** Settings ***
Documentation    Automation Exercise UI smoke tests using SeleniumLibrary and page objects.
Resource         ../../resources/ui/Browser.robot
Resource         ../../resources/ui/HomePage.robot
Resource         ../../resources/ui/ProductsPage.robot
Resource         ../../resources/ui/ProductDetailsPage.robot
Resource         ../../resources/ui/CartPage.robot
Resource         ../../resources/ui/LoginPage.robot
Resource         ../../resources/ui/Footer.robot
Library          Collections
Library          String

Suite Setup      Open Browser To Automation Exercise
Suite Teardown   Close Automation Browser
Test Setup       Go To Home Page

*** Test Cases ***
Home Navigation And Product Search
    [Documentation]    Validate navigation from home to products and search results.
    Home Page Should Be Visible
    Open Products Page
    Products Page Should Be Visible
    Search For Product    dress

Invalid Login Shows Error Banner
    [Documentation]    Attempt to log in with invalid credentials and verify the error.
    Home Page Should Be Visible
    Open Signup Login Page
    Attempt Login With Credentials    rf-ui-bot@example.com    wrong-password
    Should See Invalid Login Error

Add Product To Cart Displays In Summary
    [Documentation]    Add a product to the cart and ensure it appears in the cart summary.
    Home Page Should Be Visible
    Open Products Page
    Products Page Should Be Visible
    Open First Product Details
    Add Product To Cart And View Cart
    Cart Should Contain Items

Footer Subscription Confirmation
    [Documentation]    Subscribe to the newsletter and confirm the success banner.
    Home Page Should Be Visible
    Scroll To Footer
    ${random_id}=    Generate Random String    6    [LETTERS]
    ${email}=        Set Variable    rf-ui-bot+${random_id}@example.com
    Subscribe With Email    ${email}
    Should See Subscription Success
