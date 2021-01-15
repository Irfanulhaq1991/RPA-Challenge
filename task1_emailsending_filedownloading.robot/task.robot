*** Settings ***
Library     Autosphere.Tables
Library     Autosphere.Browser
Library     Collections
Library     Autosphere.FileSystem
Library     Autosphere.Email.ImapSmtp    smtp_server=smtp.gmail.com    smtp_port=587
Variables   Resources/config.yaml

*** Variable ***
${ADD_USER_FORM_URL}                    ${const.url}
${EMAIL}                                ${const.email}
${PASSWORD}                             ${const.password}
${RECEIVED_EMAIL_SUBJECT_FILTER}        ${const.subject_filter}
${SEND_EMAIL_SUBJECT}                   ${const.subject}
${SEND_EMAIL_BODY}                      ${const.email_body}
${FILE_DIR}                             ${const.filedir}
${TEST_FILE}                            ${const.testFile}


#*** Tasks ***
#Send Email
#    Login With Email And Password  ${EMAIL}    ${PASSWORD}
#    Send Email With Attachment     ${EMAIL}    ${RECEIVED_EMAIL_SUBJECT_FILTER}    ${SEND_EMAIL_BODY}    ${TEST_FILE}

*** Tasks ***
Download Attachement, Fetch Data From The Attachment, And Fill The Form With Feched Data
     Login With Email And Password                 ${EMAIL}       ${PASSWORD}
     @{emails_list} =  List Email With Subject     ${RECEIVED_EMAIL_SUBJECT_FILTER}
     ${emails_count} =  Get length                 ${emails_list}
     Create New Directory                          ${FILE_DIR}
     Run keyword If                                ${emails_list}[0][Has-Attachments] == True
     ...    Process Attachment In The Email        ${emails_list}[0]   ${FILE_DIR}
     ...    ELSE
     ...    Reply To Email                         ${emails_list}[0]  ${SEND_EMAIL_SUBJECT}   ${SEND_EMAIL_BODY}



### Start Of Email Opertions
*** Keywords ***
Login With Email And Password
      [Arguments]   ${email}    ${password}
      Authorize   account=${EMAIL}    password=${PASSWORD}

*** Keywords ***
Reply To Email
    [Arguments]     ${recieved_email}  ${subject}  ${body}
    Send Message      sender=${const.email}
    ...             recipients="${recieved_email}[From]"
    ...             subject="${subject}"
    ...             body="${body}"

*** Keywords ***
Send Email With Attachment
    [Arguments]     ${recipient}  ${subject}  ${body}  ${attachment}
    Send Message      sender=${const.email}
    ...             recipients=${recipient}
    ...             subject=${subject}
    ...             body=${body}
    ...             attachments=${attachment}



*** Keywords ***
List Email With Subject
  [Arguments]     ${subject}
  ${email_list} =  Create List
  @{emails}    List Messages    SUBJECT "${subject}"
  FOR  ${email}  IN    @{emails}
       Append To List    ${email_list}    ${email}
       Exit For Loop
  END
   [Return]    @{email_list}



*** Keywords ***
Process Attachment In The Email
  [Arguments]                                   ${email}  ${dir}
  Save Attachment                               ${email}    target_folder=${dir}     overwrite=True
  ${is_dir_not_empty}=                          Is Directory Not Empty    ${dir}
  Run Keyword If                                ${is_dir_not_empty} == True
  ...  Enter the CSV File Data In The Portal    ${dir}   ${email}
  ...  ELSE
  ...  Log   Attachment Not Exist

### End Of Eamil Operations

### Start Of File Operations

*** Keywords ***
Create New Directory
  [Arguments]                            ${dir}
  ${status}=  Does Directory Exist       ${dir}
  Run Keyword If                         ${status} == False
  ...      Create Directory              ${dir}

*** Keywords ***
Check If File Exist
   [Arguments]  ${file}
   [Return]     Does File Exist ${file}

*** Keywords ***
Enter the CSV File Data In The Portal
    [Arguments]   ${dir}    ${email}
#
    ${file_path} =   Get CSV File Path     ${dir}
    ${data} =        Read Table From Csv   ${file_path}
    ${newTbl} =  Create Table

    Add Table Column      ${data}          status
    Log                   ${data}

    FOR   ${row}    IN    @{data}

        Enter Data In The Form    ${row}
        Reply To Email            ${email}         ${email}[Subject]        ${const.reply_message}
        Update Status           ${file_path}     ${data}                   ${newTbl}                  ${row}

    END
     Write Table To Csv                  ${data}         ${file_path}

*** Keywords ***
Get CSV File Path
    [Arguments]   ${dir}
    ${files}=  List Files In Directory   ${dir}
    ${files}=  Create Table              ${files}

    Log                                  ${files}
    FOR                                  ${file}   IN   @{files}
                                         ${dir}=  Set Variable   ${file}[path]
    END
     [Return]                            ${dir}

*** Keywords ***
Update Status
    [Arguments]                         ${path}         ${table}           ${newtb}          ${row}
    @{new_list} =   Create List         ${row}[WA ID]    ${row}[Name]       ${const.status}
    Set Table Row                       ${table}        ${row}             ${new_list}



### End Of File Operations

### Start Of Web Operations
*** Keywords ***
Open Add New User Form
    Open Available Browser      ${ADD_USER_FORM_URL}
    Wait Until Page Contains    Administration
    Click Link                  Administration
    Click Element               xpath: //a[@href="/vicidial/admin.php?ADD=0A"]/font[@style="font-family:HELVETICA;font-size:12;color:WHITE"]
    Click Element               xpath: //a[@href="/vicidial/admin.php?ADD=1"]/font[@style="font-family:HELVETICA;font-size:11;color:BLACK"]


*** Keywords ***
Enter Data In The Form
    [Arguments]                 ${person}
    ${WA_ID} =  Set Variable    ${person}[WA ID]
    ${Name} =   Set Variable    ${person}[Name]
    Open Add New User Form
    Click link                   xpath: //a[@href="/vicidial/admin.php?ADD=0A"]
    Click link                   xpath: //a[@href="/vicidial/admin.php?ADD=1"]
    Input Text                   user             ${WA_ID}
    Input Text                   pass             ${const.user_pass}
    Click Element                full_name
    Input Text                   full_name        ${Name}
    Select From List By Label    user_level       3
    Select From List By Value    user_group       outboundgroup
    Click element                phone_login
    Input text                   phone_login      ${WA_ID}
    Click element                phone_pass
    Input text                   phone_pass       ${const.phone_pass}
    Click Button                 SUBMIT
    Click Link                   xpath: //a[@href="/vicidial/admin.php?ADD=999998"]
    Click LInk                   xpath: //a[@href="/vicidial/admin.php?ADD=10000000000"]
    Click Link                   xpath: //a[@href="/vicidial/admin.php?ADD=11111111111"]
    Input Text                   extension        ${WA_ID}
    Input Text                   dialplan_number  ${WA_ID}
    Input Text                   voicemail_id     ${WA_ID}
    Input Text                   outbound_cid     ${const.outbound_cid}
    Select From List By Value    user_group       outboundgroup
    Input Text                   login            ${WA_ID}
    Input Text                   phone_type       ${WA_ID}
    Input Text                   fullname         ${WA_ID}
    Click Button                 SUBMIT
    Wait Until Page Contains     HOME
    Click Button                 SUBMIT
    Click Link                   xpath: //a[@href="/vicidial/admin.php?force_logout=1"]
    Sleep                        3s
    close browser



### End Of Web Operations




