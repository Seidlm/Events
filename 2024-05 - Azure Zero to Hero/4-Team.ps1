#https://learn.microsoft.com/en-us/graph/api/team-post?view=graph-rest-1.0&tabs=http

# Get Owner ID
# Create Teams Team

#DON'T DO THIS AT HOME
$ClientID = "your Client ID"
$TenantID="your Tenant ID"
$clientSecret = "your Secret"
#DON'T DO THIS AT HOME

$MSGRAPHAPI_BaseURL="https://graph.microsoft.com/v1.0"

#Variables
$c_TeamOwner = "michael.seidl@au2mator.com" #Team Owner UPN
$C_TeamName = "ZeroToHero 2024" #Team Name
$C_TeamDescription = "Test Team Demo" #Team Description
$C_TeamVisibility = "Public" #Team Visibility - Options: Public, Private



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

#########################################




# Get Owner

#Get USer ID
$GetUser_Params = @{
   Method = "Get"
   Uri    = "$MSGRAPHAPI_BaseURL/users/$c_TeamOwner"
   header = $token_Header
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
   header = $token_Header
   body  =  $NewTeam_body
}


Invoke-RestMethod @NewTeam_Params



#Check Team creation
#do {
#    Start-Sleep -Seconds 30
#    $URL = "https://graph.microsoft.com/v1.0$($responseHeaders.Location)"
#    $TeamStatus = Invoke-RestMethod -Headers $headers -Uri $URL -Method GET
#
#} until ($TeamStatus.Status -eq "succeeded")




#Add Member to Teams
#$SplitMembers = $c_TeamMember.split(";")
#foreach ($Member in $SplitMembers) {
#    $TempMember = $Member
#
#    $URLMember = "https://graph.microsoft.com/v1.0/users/$TempMember"
#    $ResultMember = Invoke-RestMethod -Headers $headers -Uri $URLMember -Method Get
#
#    $URLAddMember = "https://graph.microsoft.com/v1.0$($responseHeaders.'Content-Location')/members"
#
#    $BodyJsonAddMember = @"
#                {
#                    "@odata.type": "#microsoft.graph.aadUserConversationMember",
#                    "roles": ["member"],
#                    "user@odata.bind": "https://graph.microsoft.com/v1.0/users('$($ResultMember.id)')"
#                }
#"@
#
#    Invoke-RestMethod -Headers $headers -Uri $URLAddMember -Method POST -Body $BodyJsonAddMember
#}

