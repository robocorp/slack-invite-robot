*** Settings ***
Documentation   Invite user to Slack workspace
Library         String
Library         RPA.Browser.Selenium
Library         RPA.Robocorp.Vault
Library         RPA.Robocorp.WorkItems


*** Variables ***
${SLACK_WORKSPACE_ID}=  robocorp-developers

*** Keywords ***
Login to Slack
    [Arguments]     ${user_name}    ${password}
    Wait Until Page Contains Element  alias:Slack login username
    Sleep  1
    Input Text When Element Is Visible  //input[@data-qa="login_email"]  ${user_name}
    Press Keys  //input[@data-qa="login_email"]  CONTROL + A
    Input Password  //input[@data-qa="login_password"]  ${password}
    Sleep  1
    Click Button   	//button[@id="signin_btn"]

*** Keywords ***
Send invite
    [Arguments]     ${invitee_email}
    # Click "Invite People" button once it appears
    Click Button When Visible  class:p-admin_table_wrapper__invite_btn
    # Input email of user to invite once dialog is open
    Wait Until Page Contains Element  //div[@data-qa="invite_modal_select"]
    Sleep  1
    # Email addresses may have '+', which is treated as a special
    # character by Press Keys
    ${escaped_email}=  Replace String  ${invitee_email}  +  \ue025
    Press Keys  //div[@data-qa="invite_modal_select"]  ${escaped_email}
    # Press enter on invitee list to trigger verification of emails
    Press Keys  //div[@data-qa="invite_modal_select"]  RETURN
    # Give time for verification to complete
    Sleep  3
    # Press "Send" button.
    # Press Keys is used as a workaround to Element is not clickable at point ... Other element would receive the click...
    Press Keys  css:button[data-qa="invite-to-workspace-modal-invite-form-send-button"]  RETURN
    # Wait until invites are sent and invitees list appears.
    # TODO: consider verifying the invitee list contains our user to be invited?
    Wait Until Page Contains Element  css:span[data-qa="invite-entity-invitee"]

*** Tasks ***
Invite user to Slack
    Set Selenium Implicit Wait  5
    Set Selenium Timeout    30
    ${invitee_email}=       Get work item variable    email
    Log                     Inviting ${invitee_email} to Slack workspace ${SLACK_WORKSPACE_ID}
    Open Available Browser  https://${SLACK_WORKSPACE_ID}.slack.com/admin
    ${secret}=              Get Secret    slack_invite_credentials
    Login to Slack          ${secret}[username]     ${secret}[password]
    Send invite             ${invitee_email}
