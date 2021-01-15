*** Settings ***
Library    Autosphere.Browser
Library    Autosphere.Excel.Files
Variables  Resources/config.yaml
*** Variables ***
${url}  ${dic.url}


*** Tasks ***
Form Filling Task
   Open Data Entry Form
   Initiate Form Filling Process
   Read Excel Data And Fill the Form




*** Keywords ***
Open Data Entry Form
    Open Available Browser  ${url}


*** Keywords ***
Initiate Form Filling Process
    Click Button    Start



*** Keywords ***
Read Excel Data And Fill the Form
    Open Workbook   Resources/challenge.xlsx
    ${personal_info}=   Read Worksheet As Table   header=True
    Close Workbook
    FOR     ${info}     IN      @{personal_info}
        Fill Form With Data     ${info}
    END



*** Keywords ***
Fill Form With Data
    [Arguments]     ${personal_data}
    Input Text  xpath://input[@ng-reflect-name='labelFirstName']        ${personal_data}[First Name]
    Input Text  xpath://input[@ng-reflect-name='labelLastName']         ${personal_data}[Last Name]
    Input Text  xpath://input[@ng-reflect-name='labelAddress']          ${personal_data}[Address]
    Input Text  xpath://input[@ng-reflect-name='labelEmail']            ${personal_data}[Email]
    Input Text  xpath://input[@ng-reflect-name='labelPhone']            ${personal_data}[Phone Number]
    Input Text  xpath://input[@ng-reflect-name='labelRole']             ${personal_data}[Role in Company]
    Input Text  xpath://input[@ng-reflect-name='labelCompanyName']      ${personal_data}[Company Name]
    Click Button   xpath://input[@type='submit']
