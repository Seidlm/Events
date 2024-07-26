### Mastering Microsoft Graph API  Batching


#region secret vault 
#use secret vault from PowerShell here !  https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.secretmanagement/?view=ps-modules

Install-Module Microsoft.PowerShell.SecretManagement -Force -AllowClobber
Import-Module Microsoft.PowerShell.SecretManagement

Get-SecretInfo

#Set-Secret -Name "NYC_M365_Community_Days" -Secret "" -Metadata @{"ClientID"="";"AppName"="";"TenantName"="";"TenantID"=""}

$APPINFO = Get-SecretInfo NYC_M365_Community_Days

$ClientID = ($APPINFO.Metadata).ClientID
$APPName = ($APPINFO.Metadata).AppName
$TenantName = ($APPINFO.Metadata).TenantName
$tenantID = ($APPINFO.Metadata).TenantID

$clientsecret = Get-Secret -Name "NYC_M365_Community_Days" -AsPlainText


#endregion

#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#

#region Authentication

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



#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#














#region batching


$batchrequest = @"

    {
        "requests": [
          {
            "id": "1",
            "method": "GET",
            "url": "/users"
          },
          {
            "id": "2",
            "method": "GET",
            "url": "/groups/$($myGroup.id)"
          },
          {
            "id": "3",
            "method": "GET",
            "url": "/users/0690235c-977b-4fa4-83c3-a38313642a62"
          },
          {
            "id": "4",
            "method": "GET",
            "url": "/teams"
          }
        ]
      }

"@



$Batchresponse = Invoke-RestMethod -Method Post -Uri "https://graph.microsoft.com/v1.0/`$batch" -Headers $token_Header -Body $batchrequest















#Depends on


$batchrequest = @"

    {
        "requests": [
          {
            "id": "1",
            "method": "GET",
            "url": "/users"
          },
          {
            "id": "2",
            "dependsOn": [ "1" ],
            "method": "GET",
            "url": "/groups/$($myGroup.id)"
          },
          {
            "id": "3",
            "dependsOn": [ "2" ],
            "method": "GET",
            "url": "/users/0690235c-977b-4fa4-83c3-a38313642a62"
          },
          {
            "id": "4",
            "dependsOn": [ "3" ],
            "method": "GET",
            "url": "/teams"
          }
        ]
      }

"@

$Batchresponse_dependson = Invoke-RestMethod -Method Post -Uri "https://graph.microsoft.com/v1.0/`$batch" -Headers $token_Header -Body $batchrequest















#region gametime  how much users we can craete in 30 seconds ????


# List of European names
$firstNames = @("Liam", "Noah", "Oliver", "Elijah", "Lucas", "Mason", "Logan", "Alexander", "Ethan", "Jacob", "Emma", "Olivia", "Ava", "Sophia", "Mia", "Charlotte", "Amelia", "Harper", "Evelyn", "Abigail", "James", "Benjamin", "Sebastian", "Daniel", "Henry", "Michael", "Jackson", "Sebastian", "Aiden", "Matthew", "Samuel", "David", "Joseph", "Carter", "Owen", "Wyatt", "John", "Jack", "Luke", "Jayden", "Dylan", "Grayson", "Levi", "Isaac", "Gabriel", "Julian", "Mateo", "Anthony", "Jaxon", "Lincoln", "Joshua", "Christopher", "Andrew", "Theodore", "Caleb", "Ryan", "Asher", "Nathan", "Thomas", "Leo", "Isaiah", "Charles", "Josiah", "Hudson", "Christian", "Hunter", "Connor", "Eli", "Ezra", "Aaron", "Landon", "Adrian", "Jonathan", "Nolan", "Jeremiah", "Easton", "Elias", "Colton", "Cameron", "Carson", "Robert", "Angel", "Maverick", "Nicholas", "Dominic", "Jaxson", "Greyson", "Adam", "Ian", "Austin", "Santiago", "Jordan", "Cooper", "Brayden", "Roman", "Evan", "Ezekiel", "Xavier", "Jose", "Jace", "Jameson", "Leonardo", "Bryson", "Axel")
$lastNames = @("Smith", "Johnson", "Williams", "Brown", "Jones", "Miller", "Davis", "Garcia", "Rodriguez", "Wilson", "Martinez", "Anderson", "Taylor", "Thomas", "Hernandez", "Moore", "Martin", "Jackson", "Thompson", "White", "Lopez", "Lee", "Gonzalez", "Harris", "Clark", "Lewis", "Robinson", "Walker", "Perez", "Hall", "Young", "Allen", "Sanchez", "Wright", "King", "Scott", "Green", "Baker", "Adams", "Nelson", "Hill", "Ramirez", "Campbell", "Mitchell", "Roberts", "Carter", "Phillips", "Evans", "Turner", "Torres", "Parker", "Collins", "Edwards", "Stewart", "Flores", "Morris", "Nguyen", "Murphy", "Rivera", "Cook", "Rogers", "Morgan", "Peterson", "Cooper", "Reed", "Bailey", "Bell", "Gomez", "Kelly", "Howard", "Ward", "Cox", "Diaz", "Richardson", "Wood", "Watson", "Brooks", "Bennett", "Gray", "James", "Reyes", "Cruz", "Hughes", "Price", "Myers", "Long", "Foster", "Sanders", "Ross", "Morales", "Powell", "Sullivan", "Russell", "Ortiz", "Jenkins", "Gutierrez", "Perry", "Butler", "Barnes", "Fisher", "Henderson", "Coleman", "Simmons")


#create all combinations of first and last names into an object

$allnames = @()
foreach($first in $firstNames)
{
    foreach($last in $lastNames)
    {
        $allnames += "$first $last"
    }
}

$allnames.count





# Create user requests
$userRequests = @()

$userRequests = for ($i = 1; $i -le $allnames.count; $i++) {
    

    $firstName = $allnames[$i - 1].Split(" ")[0]
    $LastName = $allnames[$i - 1].Split(" ")[1]

    @{
        id = $i
        method = "POST"
        url = "/users"
        body = @{
            accountEnabled = $false
            displayName = "$firstName $lastName"
            mailNickname = "$firstName$lastName"
            userPrincipalName = "$firstName$lastName@8knn7n.onmicrosoft.com"
            passwordProfile = @{
                forceChangePasswordNextSignIn = $true
                password = "YourS3cureP@ssword$i"
            }
            city = "New York"
        }
        headers = @{
            "Content-Type" = "application/json"
        }
    }
}









#region standard api https request



$responses = @()


foreach($user in $userrequests)
{
    
$response = Invoke-RestMethod -Method Post -Uri "https://graph.microsoft.com/v1.0/users" -Headers $token_Header -Body ($user.body | ConvertTo-Json) 
$responses += $response

}

$responses.count

#endregion














#region create user with batch request

$Batchresponses = @()
$counter = [pscustomobject] @{ Value = 0 }
$BatchgroupSize = 20
$BatchGroups = $($userRequests) | Group-Object -Property { [math]::Floor($counter.Value++ / $BatchgroupSize) }


foreach($Group in $BatchGroups)
{
    $BatchRequests = [pscustomobject][ordered]@{ 
        requests = $($Group.Group)
    }

    $batchBody = $BatchRequests | ConvertTo-Json -Depth 6

$Batchresponse = Invoke-RestMethod -Method Post -Uri "https://graph.microsoft.com/v1.0/`$batch" -Headers $token_Header -Body $batchBody
$Batchresponses += $Batchresponse
}


$Batchresponses.responses.count



#endregion


















#region Remove all Users with city New York in this Batch

# Get users from New York
$URI = "https://graph.microsoft.com/v1.0/users?`$filter=city eq 'New York'"
$URI = "https://graph.microsoft.com/v1.0/users?`$filter=city eq 'Linz'"
$response = Invoke-RestMethod -Method Get -Uri $URI -Headers $token_Header
$users = $Response.value


while ($response.'@odata.nextLink' -ne $null) {

    $response = (Invoke-RestMethod -Uri $($Response.'@odata.nextLink') -Headers $token_Header -Method Get)
    $Users += $Response.value
}


# Create user delete requests

$i = 1
$userDeleteRequests = $users| ForEach-Object {
    @{
        id = $i++
        method = "DELETE"
        url = "/users/$($_.id)"
    }
}

$counter = [pscustomobject] @{ Value = 0 }
$BatchgroupSize = 20
$BatchGroups = $($userDeleteRequests) | Group-Object -Property { [math]::Floor($counter.Value++ / $BatchgroupSize) }



foreach($Group in $BatchGroups)
{
    $BatchRequests = [pscustomobject][ordered]@{ 
        requests = $($Group.Group)
    }

    $batchBody = $BatchRequests | ConvertTo-Json -Depth 6

$Batchresponse = Invoke-RestMethod -Method Post -Uri "https://graph.microsoft.com/v1.0/`$batch" -Headers $token_Header -Body $batchBody
}

#endregion


