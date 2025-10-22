*** Settings ***
Library    Browser
Resource   Browser.robot

*** Keywords ***
Products Page Should Be Visible
    [Documentation]    Ensure the products grid is rendered.
    Wait For Url To Contain    /products
    Wait For Elements State    css=.features_items .product-image-wrapper >> nth=0    visible

Search For Product
    [Arguments]    ${query}
    [Documentation]    Search for a product using the catalogue search box.
    Fill Text    css=#search_product    ${query}
    Click    css=#submit_search
    Wait For Elements State    css=.features_items .product-image-wrapper >> nth=0    visible

Open First Product Details
    [Documentation]    Open the details page for the first product in the list.
    Click    css=.choose a[href*='product_details'] >> nth=0
    Wait For Url To Contain    /product_details/
