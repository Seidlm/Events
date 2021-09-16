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



########################
$URL="https://graph.microsoft.com/v1.0/users/jasmine.hofmeister@au2mator.com"

$body=@"
{
    "jobTitle": "Customer Manager PDCCONF Demo",
    "mobilePhone" : "+43 54 56 55 "
}
"@
Invoke-RestMethod -Method PATCH -Uri $URL -Headers $headers -Body $body
Invoke-RestMethod -Method GET -Uri $URL -Headers $headers    















#$URLGet="https://graph.microsoft.com/v1.0/users/jasmine.hofmeister@au2mator.com"
#Invoke-RestMethod -Method GET -Uri $URLGet -Headers $headers
#
#
#$URLPatch="https://graph.microsoft.com/v1.0/users/jasmine.hofmeister@au2mator.com"
#$body=@"
#{
#    "jobTitle": "Customer Manager 3"
#}
#"@
#Invoke-RestMethod -Uri $URLPatch -Method PATCH -Headers $headers -Body $body

