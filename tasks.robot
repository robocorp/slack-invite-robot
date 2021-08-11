*** Settings ***
Documentation   Slack invite bot
Library         RPA.Browser.Playwright
Library         RPA.Robocloud.Secrets
Library         RPA.Robocloud.Items


*** Variables ***
${SLACK_WORKSPACE_ID}=  robocorp-developers

*** Keywords ***
Login to Slack
    [Arguments]     ${user_name}    ${password}
    Wait Until Page Contains Element  alias:Slack login username
    # I am not sure why but login email doesnt always get filled
    # unless we give the form some time...
    Sleep  1
    Input Text      alias:Slack login username   ${user_name}
    Input Password  alias:Slack login password  ${password}
    Click Button   	//button[@id="signin_btn"]

*** Keywords ***
Send invite
    [Arguments]     ${invitee_email}
    # Click "Invite People" button once it appears
    Click Button When Visible  class:p-admin_table_wrapper__invite_btn
    # Input email of user to invite once dialog is open
    Input Text When Element Is Visible  id:invite_modal_select  ${invitee_email}

    # Press enter on invitee list to trigger verification of emails
    Press Keys  css:div[data-qa="invite_modal_select"]  RETURN
    # Give time for verification to complete
    Sleep  3
    # Press "Send" button.
    # Press Keys is used as a workaround to Element is not clickable at point ... Other element would receive the click...
    Press Keys  css:button[data-qa="invite-to-workspace-modal-invite-form-send-button"]  RETURN
    # Wait until invites are sent and invitees list appears.
    # TODO: consider verifying the invitee list contains our user to be invited?
    Wait Until Page Contains Element  css:span[data-qa="invites-summary-message-header-invitees-list"]

*** Tasks ***
Invite user to Slack
    ${invitee_email}=       Get work item variable    email
    Log                     Inviting ${invitee_email} to Slack workspace ${SLACK_WORKSPACE_ID}
    #New Page                https://${SLACK_WORKSPACE_ID}.slack.com/admin
    Open Browser            https://${SLACK_WORKSPACE_ID}.slack.com/admin
    ${secret}=              Get Secret    slack_invite_credentials
    Login to Slack          ${secret}[username]     ${secret}[password]
    Send invite             ${invitee_email}


