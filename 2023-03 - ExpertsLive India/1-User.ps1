#https://learn.microsoft.com/en-us/graph/api/user-update?view=graph-rest-1.0&tabs=http

# Get User Prop
# Update User Prop

$ClientID = "yourClientID"
$TenantID="yourTenantID"
$ClientSecret="yourSecret"

#Variables
$UserUPN="jasmine.hofmeister@au2mator.com"
$jobTitle="Customer Manager ExpertsLive India 2023 Demo"
$mobilePhone="+43 664 51515115"



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


########################
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