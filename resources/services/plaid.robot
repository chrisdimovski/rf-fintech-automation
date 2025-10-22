*** Settings ***
Resource    ../transport/http_client.robot
Library     JSONLibrary
Library     Collections
Library     BuiltIn
Library     OperatingSystem
Library     String

*** Variables ***
${PLAID_BASE}       https://sandbox.plaid.com
${INSTITUTION_ID}   ins_109508
@{PRODUCTS}         transactions
${TIMEOUT}          15

${ACCESS_TOKEN}     ${None}
${ITEM_ID}          ${None}
${SYNC_CURSOR}      ${None}
${PLAID_ENV_LOADED}    ${False}
${PLAID_WARNINGS_DISABLED}    ${False}

*** Keywords ***
_Plaid Headers
    ${h}=    Create Dictionary    Content-Type=application/json
    RETURN    ${h}

_Maybe Load Plaid Creds From Env File
    IF    ${PLAID_ENV_LOADED}
        RETURN
    END
    ${env_path}=    Normalize Path    ${CURDIR}/../../.env
    ${exists}=    Run Keyword And Return Status    File Should Exist    ${env_path}
    IF    not ${exists}
        Log    No .env file found at ${env_path}. Skipping Plaid env bootstrap.    level=DEBUG
        Set Suite Variable    ${PLAID_ENV_LOADED}    ${True}
        RETURN
    END
    ${raw}=    Get File    ${env_path}
    ${lines}=    Split To Lines    ${raw}
    FOR    ${line}    IN    @{lines}
        ${stripped}=    Strip String    ${line}
        IF    '${stripped}' == ''
            Continue For Loop
        END
        ${first_char}=    Get Substring    ${stripped}    0    1
        IF    '${first_char}' == '#'
            Continue For Loop
        END
        ${parts}=    Split String    ${stripped}    =    1
        ${parts_len}=    Get Length    ${parts}
        IF    ${parts_len} < 2
            Continue For Loop
        END
        ${key}=    Get From List    ${parts}    0
        ${value}=    Get From List    ${parts}    1
        ${key}=    Strip String    ${key}
        ${value}=    Strip String    ${value}
        IF    '${key}' == ''
            Continue For Loop
        END
        ${existing}=    _Read Env Var    ${key}
        IF    '${existing}' != 'None' and '${existing}' != ''
            Continue For Loop
        END
        Set Environment Variable    ${key}    ${value}
    END
    Set Suite Variable    ${PLAID_ENV_LOADED}    ${True}

_Disable Plaid TLS Warnings
    IF    ${PLAID_WARNINGS_DISABLED}
        RETURN
    END
    Evaluate    __import__('warnings').filterwarnings('ignore', message='urllib3 v2 only supports OpenSSL 1.1.1+')
    Evaluate    __import__('urllib3').disable_warnings(__import__('urllib3').exceptions.InsecureRequestWarning)
    Set Suite Variable    ${PLAID_WARNINGS_DISABLED}    ${True}

_Read Env Var
    [Arguments]    ${key}
    ${value}=    Evaluate    __import__('os').environ.get('''${key}''')
    RETURN    ${value}

_Get Plaid Creds
    ${cid}=    _Read Env Var    PLAID_CLIENT_ID
    ${sec}=    _Read Env Var    PLAID_SECRET
    Run Keyword If    ('${cid}' == 'None' or '${cid}' == '' or '${sec}' == 'None' or '${sec}' == '')    _Maybe Load Plaid Creds From Env File
    ${cid}=    _Read Env Var    PLAID_CLIENT_ID
    ${sec}=    _Read Env Var    PLAID_SECRET
    Run Keyword If    '${cid}' == 'None' or '${cid}' == ''    Fail    PLAID_CLIENT_ID is not set. Configure it as an environment variable or in .env.
    Run Keyword If    '${sec}' == 'None' or '${sec}' == ''    Fail    PLAID_SECRET is not set. Configure it as an environment variable or in .env.
    RETURN    ${cid}    ${sec}

_Plaid Auth Merge
    [Arguments]    &{extra}
    ${cid}    ${sec}=    _Get Plaid Creds
    ${payload}=    Create Dictionary    client_id=${cid}    secret=${sec}
    FOR    ${key}    ${value}    IN    &{extra}
        Set To Dictionary    ${payload}    ${key}=${value}
    END
    RETURN    ${payload}

Create Plaid Session
    _Disable Plaid TLS Warnings
    Create API Session    plaid    ${PLAID_BASE}    ${TIMEOUT}

Create Sandbox Public Token
    [Arguments]    ${institution_id}=${INSTITUTION_ID}    @{products}
    Create Plaid Session
    ${headers}=    _Plaid Headers
    ${body}=       Create Dictionary    institution_id=${institution_id}
    ${product_list}=    Create List    @{products}
    ${count}=    Get Length    ${product_list}
    ${count}=    Convert To Integer    ${count}
    IF    ${count} == 0
        ${product_list}=    Create List    transactions
    END
    Log    Plaid products: ${product_list}
    Set To Dictionary    ${body}    initial_products=${product_list}
    ${webhook}=    Get Environment Variable    PLAID_WEBHOOK_URL    ${EMPTY}
    IF    '${webhook}' != ''
        ${options}=    Create Dictionary    webhook=${webhook}
        Set To Dictionary    ${body}    options=${options}
    END
    ${payload}=    _Plaid Auth Merge    &{body}
    ${resp}=       POST JSON    plaid    /sandbox/public_token/create    ${headers}    ${payload}
    Plaid Should Be 200 Or Fail With Error    ${resp}
    ${j}=          Set Variable    ${resp.json()}
    RETURN         ${j["public_token"]}

Exchange Public Token For Access Token
    [Arguments]    ${public_token}
    Create Plaid Session
    ${headers}=    _Plaid Headers
    ${body}=       Create Dictionary    public_token=${public_token}
    ${payload}=    _Plaid Auth Merge    &{body}
    ${resp}=       POST JSON    plaid    /item/public_token/exchange    ${headers}    ${payload}
    Plaid Should Be 200 Or Fail With Error    ${resp}
    ${j}=          Set Variable    ${resp.json()}
    Set Suite Variable    ${ACCESS_TOKEN}    ${j["access_token"]}
    Set Suite Variable    ${ITEM_ID}        ${j["item_id"]}
    RETURN         ${ACCESS_TOKEN}    ${ITEM_ID}

Accounts Get
    [Arguments]    ${access_token}=${ACCESS_TOKEN}
    Create Plaid Session
    ${headers}=    _Plaid Headers
    ${body}=       Create Dictionary    access_token=${access_token}
    ${payload}=    _Plaid Auth Merge    &{body}
    ${resp}=       POST JSON    plaid    /accounts/get    ${headers}    ${payload}
    RETURN         ${resp}

Balances Get
    [Arguments]    ${access_token}=${ACCESS_TOKEN}
    Create Plaid Session
    ${headers}=    _Plaid Headers
    ${body}=       Create Dictionary    access_token=${access_token}
    ${payload}=    _Plaid Auth Merge    &{body}
    ${resp}=       POST JSON    plaid    /accounts/balance/get    ${headers}    ${payload}
    RETURN         ${resp}

Transactions Sync
    [Arguments]    ${access_token}=${ACCESS_TOKEN}    ${cursor}=${SYNC_CURSOR}    ${count}=100
    Create Plaid Session
    ${headers}=    _Plaid Headers
    ${count_int}=  Convert To Integer    ${count}
    ${body}=       Create Dictionary    access_token=${access_token}    count=${count_int}
    IF    '${cursor}' != '${None}'
        Set To Dictionary    ${body}    cursor=${cursor}
    END
    ${payload}=    _Plaid Auth Merge    &{body}
    ${resp}=       POST JSON    plaid    /transactions/sync    ${headers}    ${payload}
    ${j}=          Set Variable    ${resp.json()}
    ${next}=       Set Variable    ${j.get("next_cursor")}
    Set Suite Variable    ${SYNC_CURSOR}    ${next}
    RETURN         ${resp}

Fire Sandbox Transactions Webhook
    [Arguments]    ${access_token}=${ACCESS_TOKEN}    ${webhook_code}=DEFAULT_UPDATE
    Create Plaid Session
    ${headers}=    _Plaid Headers
    ${body}=       Create Dictionary    access_token=${access_token}    webhook_type=TRANSACTIONS    webhook_code=${webhook_code}
    ${payload}=    _Plaid Auth Merge    &{body}
    ${resp}=       POST JSON    plaid    /sandbox/item/fire_webhook    ${headers}    ${payload}
    RETURN         ${resp}

Plaid Should Be 200 Or Fail With Error
    [Arguments]    ${resp}
    Run Keyword If    ${resp.status_code} != 200    Fail    HTTP ${resp.status_code} from Plaid. Body: ${resp.text}
