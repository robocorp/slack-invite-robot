*** Settings ***
Documentation   Invite user to Slack workspace
Library         String
Library         RPA.Browser.Selenium
Library         RPA.Robocorp.Vault
Library         RPA.Robocorp.WorkItems


*** Variables ***
${SLACK_WORKSPACE_ID}=  sema4ai-users

*** Keywords ***
Login to Slack
    [Arguments]     ${user_name}    ${password}
    Wait Until Page Contains Element  alias:Slack login username
    Sleep  1
    Input Text      alias:Slack login username  ${user_name}
    Input Password  alias:Slack login password  ${password}
    Sleep  1
    Click Button   	//button[@id="signin_btn"]

*** Keywords ***
Send invite
    [Arguments]     ${invitee_email}
    # Click "Invite People" button once it appears
    Click Button When Visible  //button[@data-qa="page_header_primary_button"]
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
    Press Keys  xpath://button[contains(text(), 'Send')]  RETURN
    # Wait until invites are sent and invitees list appears.
    # TODO: consider verifying the invitee list contains our user to be invited?
    Wait Until Page Contains Element  css:span[data-qa="invite-entity-invitee"]

*** Tasks ***
Invite user to Slack
    Set Selenium Implicit Wait  15
    Set Selenium Timeout    60
    ${invitee_email}=       Get work item variable    email
    Log                     Inviting ${invitee_email} to Slack workspace ${SLACK_WORKSPACE_ID}
    Open Available Browser  https://${SLACK_WORKSPACE_ID}.slack.com/sign_in_with_password?redir=%2Fadmin
    ${secret}=              Get Secret    slack_invite_credentials
    Login to Slack          ${secret}[username]     ${secret}[password]
    Send invite             ${invitee_email}
