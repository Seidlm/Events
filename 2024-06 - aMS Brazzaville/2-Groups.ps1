#https://learn.microsoft.com/en-us/graph/api/group-post-groups?view=graph-rest-1.0&tabs=http

# New Azure AD Group
# Add User to Group


#DON'T DO THIS AT HOME
$ClientID = "your Client ID"
$TenantID="your Tenant ID"
$clientSecret = "Your Secret"
#DON'T DO THIS AT HOME



$MSGRAPHAPI_BaseURL = "https://graph.microsoft.com/v1.0"

#Variables
$GroupName = "DEMO-aMSBrazzaville" #Name of new Group
$GroupDescription = "Thats my new Group" #Description of new Group
$UserUPN = "jasmine.hofmeister@au2mator.com" #User to add to Group


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

