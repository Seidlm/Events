#DON'T DO THIS AT HOME
$ClientID = "your Client ID"
$TenantID="your Tenant ID"
$clientSecret = "Your Secret"
#DON'T DO THIS AT HOME

#Authentication
#Connect to GRAPH API
$token_Body = @{
    Grant_Type    = "client_credentials"
    Scope         = "https://graph.microsoft.com/.default"
    Client_Id     = $clientId
    Client_Secret = $clientSecret
}
$token_Response = Invoke-RestMethod -Uri "https://login.microsoftonline.com/$tenantID/oauth2/v2.0/token" -Method POST -Body $token_Body
$token_Header = @{
    "Authorization" = "Bearer $($token_Response.access_token)"
    "Content-type"  = "application/json"
}


#Authentication MAIL and Teams
#DON'T DO THIS AT HOME
$ClientID_MAIL = "your Client ID"
$TenantID_MAIL="your Tenant ID"
$clientSecret_MAIL = "your Secret"
#DON'T DO THIS AT HOME


#Connect to GRAPH API
$token_Body = @{
    Grant_Type    = "client_credentials"
    Scope         = "https://graph.microsoft.com/.default"
    Client_Id     = $ClientID_MAIL
    Client_Secret = $clientSecret_MAIL
}
$token_Response = Invoke-RestMethod -Uri "https://login.microsoftonline.com/$TenantID_MAIL/oauth2/v2.0/token" -Method POST -Body $token_Body
$token_Header_Mail = @{
    "Authorization" = "Bearer $($token_Response.access_token)"
    "Content-type"  = "application/json"
}



$MSGRAPHAPI_BaseURL = "https://graph.microsoft.com/v1.0"




########################
#USER MANIPULATION
########################

#Variables
$UserUPN="yourUser@8knn7n.onmicrosoft.com" #Target User UPN
$jobTitle="NYC Community Days 365 Manager" #New Job Title
$mobilePhone="+43 664 1234567" #New Mobile Phone Number

#GET
$GET_URL="https://graph.microsoft.com/v1.0/users/$UserUPN"
$Response=Invoke-RestMethod -Method GET -Uri $GET_URL -Headers $token_Header
$Response


#SET
$Set_body=@"
{
    "jobTitle": "$jobTitle",
    "mobilePhone" : "$mobilePhone"
}
"@

$SET_URL="https://graph.microsoft.com/v1.0/users/$UserUPN"


Invoke-RestMethod -Method PATCH -Uri $SET_URL -Headers $token_Header -Body $Set_body






########################
#GROUP MANAGEMENT
########################


#Variables
$GroupName = "DEMO-NYCCommunityDays2024" #Name of new Group
$GroupDescription = "Thats my new Group" #Description of new Group


#New Group
$NewGroup_Body = @"
{
    "description": "$GroupDescription",
    "displayName": "$GroupName",
    "groupTypes": [
    ],
    "mailEnabled": false,
    "mailNickname": "library",
    "securityEnabled": true
}
"@

$NewGroup_Params = @{
    Method = "POST"
    Uri    = "$MSGRAPHAPI_BaseURL/groups/"
    header = $token_Header
    body   = $NewGroup_Body
}

$NewGroup_Result = Invoke-RestMethod @NewGroup_Params


#Get USer ID
$GetUser_Params = @{
    Method = "Get"
    Uri    = "$MSGRAPHAPI_BaseURL/users/$UserUPN"
    header = $token_Header
}

$GetUser_Result = Invoke-RestMethod @GetUser_Params



#Add User to Group
$AddUserToGroup_Body = @"
{
    "@odata.id": "https://graph.microsoft.com/v1.0/directoryObjects/$($GetUser_Result.id)"
}
"@

$AddUserToGroup_Params = @{
    Method = "POST"
    Uri    = "$MSGRAPHAPI_BaseURL/groups/$($NewGroup_Result.id)/members/`$ref"
    header = $token_Header
    body   = $AddUserToGroup_Body
}

Invoke-RestMethod @AddUserToGroup_Params





########################
#SEND MAIL
########################

#Variables
$MailSender = "michael.seidl@au2mator.com"
$Recipient = "powershellworks@8knn7n.onmicrosoft.com"



#Send Mail    
$MailSend_Body = @"
                    {
                        "message": {
                          "subject": "Hello World from Microsoft Graph API",
                          "body": {
                            "contentType": "HTML",
                            "content": "This Mail is sent via Microsoft <br>
                            <br>
                            <br>
                            GRAPH <br>
                            API<br>
                            <br>
                            <br>
                            NYC Communiy 365 Days 2024
                            <br>
                            <br>
                            <br>
                            <br>
                            <br>
                            "
                          },
                          "toRecipients": [
                            {
                              "emailAddress": {
                                "address": "$Recipient"
                              }
                            }
                          ]
                        },
                        "saveToSentItems": "true"
                      }
"@

$MailSend_Params = @{
  Method = "POST"
  Uri    = "$MSGRAPHAPI_BaseURL/users/$MailSender/sendMail"
  header = $token_Header_Mail
  body   = $MailSend_Body
}


Invoke-RestMethod @MailSend_Params




########################
#TEAMS Management
##ä########################

#Variables
#$c_TeamOwner = "michael.seidl@au2mator.com" #Team Owner UPN
$c_TeamOwner = "Ahmed.Uzejnovic@au2mator.com" #Team Owner UPN
$C_TeamName = "NYC Community Days 2024" #Team Name
$C_TeamDescription = "Test Team Demo" #Team Description
$C_TeamVisibility = "Public" #Team Visibility - Options: Public, Private





#Get USer ID
$GetUser_Params = @{
    Method = "Get"
    Uri    = "$MSGRAPHAPI_BaseURL/users/$c_TeamOwner"
    header = $token_Header_Mail
 }
 
 $GetUser_Result = Invoke-RestMethod @GetUser_Params
 
 
 #Create Team
 $NewTeam_body = @"
     {
        "template@odata.bind":"https://graph.microsoft.com/v1.0/teamsTemplates('standard')",
        "displayName":"$C_TeamName",
        "description":"$C_TeamDescription",
        "visibility":"$C_TeamVisibility",
        "members":[
           {
              "@odata.type":"#microsoft.graph.aadUserConversationMember",
              "roles":[
                 "owner"
              ],
              "user@odata.bind":"https://graph.microsoft.com/v1.0/users/$($GetUser_Result.id)"
           }
        ]
     }
"@
 
 $NewTeam_Params = @{
    Method = "POST"
    Uri    = "$MSGRAPHAPI_BaseURL/teams"
    header = $token_Header_Mail
    body  =  $NewTeam_body
 }
 
 
 Invoke-RestMethod @NewTeam_Params
 