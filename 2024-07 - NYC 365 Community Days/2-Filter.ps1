### Mastering Microsoft Graph API Advanced Querys

#https://learn.microsoft.com/en-us/graph/aad-advanced-queries?tabs=http

#region secret vault 
#use secret vault from PowerShell here !  https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.secretmanagement/?view=ps-modules
Install-Module Microsoft.PowerShell.SecretManagement -Force -AllowClobber
Import-Module Microsoft.PowerShell.SecretManagement


#endregion

#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#

#region Authentication
$APPINFO = Get-SecretInfo NYC_M365_Community_Days

$ClientID = ($APPINFO.Metadata).ClientID
$tenantID = ($APPINFO.Metadata).TenantID
$clientsecret = Get-Secret -Name "NYC_M365_Community_Days" -AsPlainText

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

$token_Header_eventual = @{
    "Authorization" = "Bearer $($token_Response.access_token)"
    "Content-type"  = "application/json"
    "consistencyLevel" = "eventual" #Had to be added for advanced querys
}

#endregion

#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#

#region Get all disabled users in the Entra ID tenant 



#standard query to get users in entra id tenant
$users = (Invoke-RestMethod -Uri "https://graph.microsoft.com/v1.0/users" -Headers $token_Header).value
$users


#what happens when try to select the account enable property ?
$users = (Invoke-RestMethod -Uri "https://graph.microsoft.com/v1.0/users?`$select=accountEnabled" -Headers $token_Header).value
$users


#we have to add other properties manually if we use select.
$users = (Invoke-RestMethod -Uri "https://graph.microsoft.com/v1.0/users?`$select=displayname,givenname,mail,accountEnabled" -Headers $token_Header).value
$users



#how we do it wrong ?? -> with where-object



$users | Where-Object {$_.accountEnabled -eq $false}

#First we have to load all users from the tenatn and then filter them with where-object. 
#This is not efficient and not recommended for large tenants.



#the best option is to use a filter query to set the filter on the server side. 
#So our client only gets the data we need and not need to filter it on the client side.


#request with filter query on server

$users = (Invoke-RestMethod -Uri "https://graph.microsoft.com/v1.0/users?`$filter=accountEnabled eq false" -Headers $token_Header).value


#would this also work with ne true ????
$users = Invoke-RestMethod -Uri "https://graph.microsoft.com/v1.0/users?`$filter=accountEnabled ne true" -Headers $token_Header


#no it does not work. We have to use the advanced querys for this. 
#mention consitencyLevel=eventual in the header to use advanced querys
$users = Invoke-RestMethod -Uri "https://graph.microsoft.com/v1.0/users?`$filter=accountEnabled ne true&`$count=true" -Headers $token_Header_eventual


#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#









#endregion

#Test OneWaySync (Values get with Graph API Advanced Querys needs longer to be updated in the directory)

# User ID and new display name
$userId = "c81cc8e5-2ccd-4e48-976a-6a4f4d35db5c"
$newDisplayName = "Alexander Brown1"

# User update body
$userUpdateBody = @{
    displayName = $newDisplayName
} | ConvertTo-Json

# User update URI
$URI = "https://graph.microsoft.com/v1.0/users/$userId"

# Send the PATCH request
Invoke-RestMethod -Method Patch -Uri $URI -Headers $token_Header -Body $userUpdateBody

$user = Invoke-RestMethod -Uri "https://graph.microsoft.com/v1.0/users?`$filter=ID eq '$($userid)'" -Headers $token_Header
$user.value

$useradvanced = Invoke-RestMethod -Uri "https://graph.microsoft.com/v1.0/users?`$filter=ID eq '$($userId)'&`$count=true" -Headers $token_Header_eventual
$useradvanced.value


#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#






#region signle operators

# equals to
$URI = "https://graph.microsoft.com/v1.0/users?`$filter=displayName eq 'Alexander Brown2'"
$result = Invoke-RestMethod -Method Get -Uri $URI -Headers $token_Header
$result.value



# not equals to
$URI = "https://graph.microsoft.com/v1.0/users?`$filter=displayName ne 'Alexander Brown2'&`$count=true"
$result = Invoke-RestMethod -Method Get -Uri $URI -Headers $token_Header_eventual
$result.value




# in (equal to a value in a collection)
$URI = "https://graph.microsoft.com/v1.0/users?`$filter=displayName in ('Alexander Brown2', 'Adele Vance')&`$count=true"
$result = Invoke-RestMethod -Method Get -Uri $URI -Headers $token_Header
$result.value



# not and in (Not equal to a value in a collection)
$URI = "https://graph.microsoft.com/v1.0/users?`$filter=not(displayName in ('Alexander Brown2', 'Adele Vance'))&`$count=true"
$result = Invoke-RestMethod -Method Get -Uri $URI -Headers $token_Header_eventual





# startsWith (value starts with)
$URI = "https://graph.microsoft.com/v1.0/users?`$filter=startsWith(displayName, 'Alex')&`$count=true"
$result = Invoke-RestMethod -Method Get -Uri $URI -Headers $token_Header_eventual




# not and startsWith (value does not start with)
$URI = "https://graph.microsoft.com/v1.0/users?`$filter=not(startsWith(displayName, 'Alex'))&`$count=true"
$result = Invoke-RestMethod -Method Get -Uri $URI -Headers $token_Header_eventual




# endsWith (Value ends with)
$URI = "https://graph.microsoft.com/v1.0/users?`$filter=endsWith(UserprincipalName, 'AlexW@8knn7n.onmicrosoft.com')&`$count=true"
$result = Invoke-RestMethod -Method Get -Uri $URI -Headers $token_Header_eventual





# not and endsWith (Value does not end with)
$URI = "https://graph.microsoft.com/v1.0/users?`$filter=not(endsWith(UserPrincipalName, 'AlexW@8knn7n.onmicrosoft.com'))&`$count=true"
$result = Invoke-RestMethod -Method Get -Uri $URI -Headers $token_Header_eventual





# multiple operators in one single query
# OR
$URI = "https://graph.microsoft.com/v1.0/users?`$filter=startsWith(displayName, 'Alex') or startsWith(displayName, 'Adele')&`$count=true"
$result = Invoke-RestMethod -Method Get -Uri $URI -Headers $token_Header_eventual




# AND
$URI = "https://graph.microsoft.com/v1.0/users?`$filter=startsWith(displayName, 'Alex') and startsWith(Department, 'testdepartment')&`$count=true"
$result = Invoke-RestMethod -Method Get -Uri $URI -Headers $token_Header_eventual


#endregion




#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#