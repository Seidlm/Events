$ClientID = "your Client ID"
$TenantID="your Tenant ID"
$ClientSecret="your Secret"


#https://learn.microsoft.com/en-us/graph/api/user-update?view=graph-rest-1.0&tabs=http


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



########################
#GET
$URL="https://graph.microsoft.com/v1.0/users/jasmine.hofmeister@au2mator.com"
Invoke-RestMethod -Method GET -Uri $URL -Headers $headers



#SET
$body=@"
{
    "jobTitle": "Customer Manager Cloud8 Demo",
    "mobilePhone" : "+43 664 51515115"
}
"@


Invoke-RestMethod -Method PATCH -Uri $URL -Headers $headers -Body $body










