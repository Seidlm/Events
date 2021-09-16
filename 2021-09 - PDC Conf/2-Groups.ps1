$ClientID = "your Client ID"
$TenantID=""
$ClientSecret=""


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


$GroupName="PDCCONF2021"


# Get Group with Name and get ID

$URL="https://graph.microsoft.com/v1.0/groups"
$Result=Invoke-RestMethod -Method GET -Uri $URL -Headers $headers
$Result.value

$Result.value | Where-Object -Property Displayname -Value $GroupName -eq

$GroupID=($Result.value | Where-Object -Property Displayname -Value $GroupName -eq).id


#Add User to Group
$URL="https://graph.microsoft.com/v1.0/groups/$GroupID/members/`$ref"

$body=@"
{
    "@odata.id": "https://graph.microsoft.com/v1.0/directoryObjects/423936bb-8f7d-457f-b9f5-e0b7a645cdf0"

}
"@
Invoke-RestMethod -Uri $URL -Method POST -Headers $headers -Body $body
