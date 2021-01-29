*** Settings ***
Documentation   Template robot main suite.
Library         RPA.Browser.Selenium
Library         RPA.Robocloud.Secrets
Library         RPA.Robocloud.Items


*** Variables ***
${SLACK_WORKSPACE_ID}=  robocorp-developers

*** Keywords ***
Login to Slack
    [Arguments]     ${user_name}    ${password}
    Input Text      alias:Slack login username  ${user_name}
    Input Password  alias:Slack login password  ${password}
    Click Button   	//button[@id="signin_btn"]

*** Keywords ***
Send invite
    [Arguments]     ${invitee_email}
    Click Button When Visible  class:p-admin_table_wrapper__invite_btn
    Wait Until Page Contains Element  id:invite_modal_select

*** Tasks ***
Invite user to Slack
    ${invitee_email}=       Get work item variable    email
    Log                     Inviting ${invitee_email} to Slack workspace ${SLACK_WORKSPACE_ID}
    Open Available Browser  https://${SLACK_WORKSPACE_ID}.slack.com/admin
    ${secret}=              Get Secret    slack-credentials
    Login to Slack          ${secret}[username]     ${secret}[password]
    Send invite             ${invitee_email}
