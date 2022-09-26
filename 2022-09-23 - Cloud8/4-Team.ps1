#https://learn.microsoft.com/en-us/graph/api/team-post?view=graph-rest-1.0&tabs=http

$ClientID = "your Client ID"
$TenantID="your Tenant ID"
$ClientSecret="your Secret"


#Authentication
#Connect to GRAPH API
$tokenBody = @{
    Grant_Type    = "client_credentials"
    Scope         = "https://graph.microsoft.com/.default"
    Client_Id     = $clientId
    Client_Secret = $clientSecret
}
$tokenResponse = Invoke-RestMethod -Uri "https://login.microsoftonline.com/$tenantID/oauth2/v2.0/token" -Method POST -Body $tokenBody
$headers = @{
    "Authorization" = "Bearer $($tokenResponse.access_token)"
    "Content-type"  = "application/json"
}

#########################################





$c_TeamOwner = "michael.seidl@au2mator.com"

$C_TeamName = "cloud8"
$C_TeamDescription = "Test Team Demo"
$C_TeamVisibility = "Public"


# Get Owner
$URLOwnwer = "https://graph.microsoft.com/v1.0/users/$c_TeamOwner"
$ResultOwner = Invoke-RestMethod -Headers $headers -Uri $URLOwnwer -Method Get


#Create Team
$BodyJsonTeam = @"
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
             "user@odata.bind":"https://graph.microsoft.com/v1.0/users/$($ResultOwner.id)"
          }
       ]
    }
"@
$URLTeam = "https://graph.microsoft.com/v1.0/teams"

Invoke-RestMethod -Headers $headers -Uri $URLTeam -Method POST -Body $BodyJsonTeam #-ResponseHeadersVariable responseHeaders



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

