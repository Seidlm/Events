
#region secret vault 
#use secret vault from PowerShell here !  https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.secretmanagement/?view=ps-modules

Install-Module Microsoft.PowerShell.SecretManagement -Force -AllowClobber
Import-Module Microsoft.PowerShell.SecretManagement

Get-SecretInfo


#Set-Secret -Name "SearchdemoPW" -Secret "" -Metadata @{"ClientID"="9772e2e7-3a75-415b-8bd6-5d8e925d3b2c";"User"="powershellworks@8knn7n.onmicrosoft.com"}


$APPINFO = Get-SecretInfo SearchdemoPW

$ClientID = ($APPINFO.Metadata).ClientID
$User = ($APPINFO.Metadata).User
$pw = Get-Secret -Name "SearchdemoPW" -AsPlainText
$resource = "https://graph.microsoft.com"


#Authentication
#Connect to GRAPH API

#Connect to GRAPH API
$tokenBody = @{  
    Grant_Type = "password"  
    Scope      = "user.read%20openid%20profile%20offline_access"  
    Client_Id  = $clientId  
    username   = $User
    password   = $pw
    resource   = $resource
}   

$token_Response = Invoke-RestMethod "https://login.microsoftonline.com/common/oauth2/token" -Method Post -ContentType "application/x-www-form-urlencoded" -Body $tokenBody -ErrorAction STOP
$token_Header = @{
    "Authorization" = "Bearer $($token_Response.access_token)"
    "Content-type"  = "application/json"
}


#region function
function Get-AzureResourcePaging {
    param (
        $URL,
        $AuthHeader
    )
 
    $Response = Invoke-RestMethod -Method GET -Uri $URL -Headers $AuthHeader
    $Resources = $Response.value
   
    while ($null -ne $($Response."@odata.nextLink")) {
        $Response = (Invoke-RestMethod -Uri $($Response."@odata.nextLink") -Headers $token_Header -Method Get)
        $Resources += $Response.value
    }

    if ($null -eq $Resources) {
        $Resources = $Response
    }
    return $Resources
}

#endregion function


$search_body = @"
    {
        "requests": [
            {
              "entityTypes": [
                "message"
              ],
              "query": {
                "queryString": "NYC Community Days 2024"
              },
              "from": 0,
              "size": 25
            }
          ]
    }
"@

$Return=Invoke-RestMethod -Method POST -Uri "https://graph.microsoft.com/v1.0/search/query" -Headers $token_Header -Body $search_body

$Return.value

($Return.value.hitsContainers.hits).summary



