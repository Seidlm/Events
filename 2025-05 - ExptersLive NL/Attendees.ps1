#FILL in your Details after changing the Password (small Paper)
#DON'T DO THIS AT HOME
$User = "Your USER UPN"
$Password = "your Password"
#DON'T DO THIS AT HOME


##################
#region Exercise 1
##################
# - Create an App Reg with Leading ELNL25_*UserNumber*_*yourStuff*
# - Permissions:
#         DELEGATE: User.ReadWrite, User.ReadBasic.All, User.Read 
# - Client Flow
# Admin need to consent!!! (Break)
# Copy the Cient ID in the next line

#DON'T DO THIS AT HOME
$ClientID = "your Client ID"
#DON'T DO THIS AT HOME

#AUTENTICATION
$tokenBodyEX1 = @{  
    Grant_Type = "password"  
    Scope      = "user.read%20openid%20profile%20offline_access"  
    Client_Id  = $ClientID
    username   = $User
    password   = $Password
    resource   = "https://graph.microsoft.com"
} 
$tokenResponseEX1 = Invoke-RestMethod "https://login.microsoftonline.com/common/oauth2/token" -Method Post -ContentType "application/x-www-form-urlencoded" -Body $tokenBodyEX1 -ErrorAction STOP
$headersEX1 = @{
    "Authorization" = "Bearer $($tokenResponseEX1.access_token)"
    "Content-type"  = "application/json"
}








#Get your User Properties to get the Details
$GetUsers_Params = @{
    Method = "Get"
    Uri    = "https://graph.microsoft.com/v1.0/users/$User"
    header = $headersEX1
}

$GetUsers_Result = Invoke-RestMethod @GetUsers_Params
$GetUsers_Result











#Update User and try to change the Firstname and Lastname
# hopefully you get an error message :-)


$Firstname = "Harry"
$Lastname = "Holland"


$UpdateUser_Body = @{
    givenName = $Firstname
    surname   = $Lastname
} | ConvertTo-Json

$UpdateUser_Params = @{
    Method = "PATCH"
    Uri    = "https://graph.microsoft.com/v1.0/users/$User"
    header = $headersEX1
    Body   = $UpdateUser_Body
}

Invoke-RestMethod @UpdateUser_Params



# Admin: Assign Role and Rerun again
# Wait a few seconds
# Admin: Remove Assignment and Rerun again









#Try to update the User again with an App Permission
#DON'T DO THIS AT HOME
$ClientID = "your ClientID"
$TenantID = "your TenantID"
$clientSecret = "your Secret"
#DON'T DO THIS AT HOME


#Authentication
$token_BodyEX1b = @{
    Grant_Type    = "client_credentials"
    Scope         = "https://graph.microsoft.com/.default"
    Client_Id     = $clientId
    Client_Secret = $clientSecret
}
$token_ResponseEX1b = Invoke-RestMethod -Uri "https://login.microsoftonline.com/$tenantID/oauth2/v2.0/token" -Method POST -Body $token_BodyEX1b
$token_HeaderEX1b = @{
    "Authorization" = "Bearer $($token_ResponseEX1b.access_token)"
    "Content-type"  = "application/json"
}






#Update User
$Firstname = "Morten"
$Lastname = "Menigmand"
$UpdateUser_Body = @{
    givenName = $Firstname
    surname   = $Lastname
} | ConvertTo-Json

$UpdateUser_Params = @{
    Method = "PATCH"
    Uri    = "https://graph.microsoft.com/v1.0/users/$User"
    header = $token_HeaderEX1b
    Body   = $UpdateUser_Body
}

Invoke-RestMethod @UpdateUser_Params






##################
#endregion Exercise 1
##################



##################
#region Execise 2
##################
# Get all User without Paging and then with Paging


#DON'T DO THIS AT HOME
$ClientIDEX2 = "your ClientID"
$TenantIDEX2 = "your TenantID"
$clientSecretEX2 = "your Secret"
#DON'T DO THIS AT HOME


#Authentication
#Connect to GRAPH API
$tokenBodyEX2 = @{  
    Grant_Type    = "client_credentials"
    Scope         = "https://graph.microsoft.com/.default"
    Client_Id     = $clientIdEX2
    Client_Secret = $clientSecretEX2
}
$token_ResponseEX2 = Invoke-RestMethod -Uri "https://login.microsoftonline.com/$tenantIDEX2/oauth2/v2.0/token" -Method POST -Body $tokenBodyEX2
$headersEX2 = @{
    "Authorization" = "Bearer $($token_ResponseEX2.access_token)"
    "Content-type"  = "application/json"
}



#Get all Users from Azure AD
#The first try
$GetUsers_ParamsEX2 = @{
    Method = "Get"
    Uri    = "https://graph.microsoft.com/v1.0/users"
    header = $headersEX2
}
$GetUsers_ResultEX2 = Invoke-RestMethod @GetUsers_ParamsEX2
$GetUsers_ResultEX2.value.count






#https://learn.microsoft.com/en-us/graph/paging?tabs=http


#The second try
$GetUsers_ParamsEX2 = @{
    Method = "Get"
    Uri    = "https://graph.microsoft.com/v1.0/users?`$top=999"
    header = $headersEX2
}
$GetUsers_ResultEX2 = Invoke-RestMethod @GetUsers_ParamsEX2
$GetUsers_ResultEX2.value.count









#lets see what is happening here
#try bigger paging to see difference
$GetUsers_ParamsEX2 = @{
    Method = "Get"
    Uri    = "https://graph.microsoft.com/v1.0/users"
    header = $headersEX2
}
$GetUsers_ResultEX2 = Invoke-RestMethod @GetUsers_ParamsEX2
$GetUsers_ResultEX2.'@odata.nextLink'









#Loop
$Response = Invoke-RestMethod @GetUsers_ParamsEX2
$Resources = $Response.value
$ResponseNextLink = $Response."@odata.nextLink"
while ($ResponseNextLink -ne $null) {

    $Response = (Invoke-RestMethod -Uri $ResponseNextLink -Headers $headersEX2 -Method Get)
    $ResponseNextLink = $Response."@odata.nextLink"
    $Resources += $Response.value
}
return @($Resources.value).count














#Function
# Free to use, so USE IT!!!!
function Get-AzureResourcePaging {
    param (
        $URL,
        $AuthHeader
    )
 
    # List Get all Apps from Azure

    $Response = Invoke-RestMethod -Method GET -Uri $URL -Headers $AuthHeader
    $Resources = $Response.value

    $ResponseNextLink = $Response."@odata.nextLink"
    while ($ResponseNextLink -ne $null) {

        $Response = (Invoke-RestMethod -Uri $ResponseNextLink -Headers $AuthHeader -Method Get)
        $ResponseNextLink = $Response."@odata.nextLink"
        $Resources += $Response.value
    }
    return $Resources
}

(Get-AzureResourcePaging -URL "https://graph.microsoft.com/v1.0/users" -AuthHeader $headersEX2).value.count


#PageSize and Performance Notes




##################
#endregion Execise 2
##################



##################
#region Exercise 3
##################


#Part One: Search
#Part Two: find a User with the firstname property
#Part Three: Group Members


#Authentication Exercise3
#DON'T DO THIS AT HOME
$ClientIDEX3 = "your ClientID"
$TenantIDEX3 = "your TenantID"
$clientSecretEX3 = "your Secret"
#DON'T DO THIS AT HOME



#Authentication
#Connect to GRAPH API
$tokenBodyEX3 = @{  
    Grant_Type    = "client_credentials"
    Scope         = "https://graph.microsoft.com/.default"
    Client_Id     = $clientIdEX3
    Client_Secret = $clientSecretEX3
}
$token_ResponseEX3 = Invoke-RestMethod -Uri "https://login.microsoftonline.com/$tenantIDEX3/oauth2/v2.0/token" -Method POST -Body $tokenBodyEX3
$headersEX3 = @{
    "Authorization" = "Bearer $($token_ResponseEX3.access_token)"
    "Content-type"  = "application/json"
}

#Exercise
##SEARCH
#Example does not work
$search_body = @"
    {
        "requests": [
            {
              "entityTypes": [
                "message"
              ],
              "query": {
                "queryString": "Invoice"
              },
              "from": 0,
              "size": 25
            }
          ]
    }
"@
#$Return = Invoke-RestMethod -Method POST -Uri "https://graph.microsoft.com/v1.0/search/query" -Headers $token_Header -Body $search_body










##FILTER
#Method 1
# Get all Users and Where-Object
$AllUsers = Get-AzureResourcePaging -URL "https://graph.microsoft.com/v1.0/users" -AuthHeader $headersEX3
$AllNamedUsers = $AllUsers | Where-Object { $_.givenName -eq $Firstname } 
$AllNamedUsers














#Method 2
#get all Users with a foreach
$AllUsers = Get-AzureResourcePaging -URL "https://graph.microsoft.com/v1.0/users" -AuthHeader $headersEX3
$AllNamedUsers = @()
foreach ($User in $AllUsers) {
    if ($User.givenName -eq $Firstname) {
        $AllNamedUsers += $User
    }
}
$AllNamedUsers















#Method 3, the best Options
$AllNamedUsers = Get-AzureResourcePaging -URL "https://graph.microsoft.com/v1.0/users?`$filter=givenName eq '$Firstname'" -AuthHeader $headersEX3
$AllNamedUsers



#Other Examples
#https://learn.microsoft.com/en-us/graph/filter-query-parameter?tabs=http

$AllNamedUsers = Get-AzureResourcePaging -URL "https://graph.microsoft.com/v1.0/users?`$filter=startsWith(givenName, '$Firstname')" -AuthHeader $headersEX3
$AllNamedUsers








#Advanced
# https://learn.microsoft.com/en-us/graph/filter-query-parameter?tabs=http#**

$headersEX3ev = @{
    "Authorization"    = "Bearer $($token_ResponseEX3.access_token)"
    "Content-type"     = "application/json"
    "ConsistencyLevel" = "eventual"
}

$OtherNamedUsers = Get-AzureResourcePaging -URL "https://graph.microsoft.com/v1.0/users?`$filter=givenName ne '$FirstName'&`$count=true" -AuthHeader $headersEX3ev
$OtherNamedUsers.count


#Think about using foreach or where object now ?????










#Group Membership
# Get Members of a Group wehere Job Titel is DEV User
#https://devblogs.microsoft.com/microsoft365dev/build-advanced-queries-with-count-filter-search-and-orderby/
$GroupName = "ELNL25_50"
$GetGroupURL = "https://graph.microsoft.com/v1.0/groups?`$filter=displayname eq '$GroupName'"
$Group = Invoke-RestMethod -Method Get -Uri $GetGroupURL -Headers $headersEX3









#Way before Filtering
# Get all Members and than filter Resutl Result
$GetMemberURL = "https://graph.microsoft.com/v1.0/groups/$($Group.value.id)/members"
$Out = Invoke-RestMethod -Method Get -Uri $GetMemberURL -Headers $headersEX3

$Out.value
$out.value.count

$Out.value | Where-Object { $_.jobTitle -eq "DEV User" }
($Out.value | Where-Object { $_.jobTitle -eq "DEV User" }).count








#Way to go
$headersEX3ev = @{
    "Authorization"    = "Bearer $($token_ResponseEX3.access_token)"
    "Content-type"     = "application/json"
    "ConsistencyLevel" = "eventual"
}

$GetMemberURL = "https://graph.microsoft.com/v1.0/groups/$($Group.value.id)/members/microsoft.graph.user?`$count=true&`$filter=jobTitle eq 'DEV User'"  
$Out = Invoke-RestMethod -Method Get -Uri $GetMemberURL -Headers $headersEX3ev


$Out.value.count









##################
#endregion Exercise 3
##################



##################
#region Exercise 4
##################

# Select Properties from Users


#DON'T DO THIS AT HOME
$ClientIDEX4 = "your ClientID"
$TenantIDEX4 = "your TenantID"
$clientSecretEX4 = "your Secret"
#DON'T DO THIS AT HOME



#Authentication
#Connect to GRAPH API
$tokenBodyEX4 = @{  
    Grant_Type    = "client_credentials"
    Scope         = "https://graph.microsoft.com/.default"
    Client_Id     = $clientIdEX4
    Client_Secret = $clientSecretEX4
}
$token_ResponseEX4 = Invoke-RestMethod -Uri "https://login.microsoftonline.com/$tenantIDEX4/oauth2/v2.0/token" -Method POST -Body $tokenBodyEX4
$headersEX4 = @{
    "Authorization" = "Bearer $($token_ResponseEX4.access_token)"
    "Content-type"  = "application/json"
}









$AllUsers = Get-AzureResourcePaging -URL "https://graph.microsoft.com/v1.0/users" -AuthHeader $headersEX4
$AllUsers[0]
#Properties: https://learn.microsoft.com/en-us/graph/api/resources/user?view=graph-rest-1.0#properties





#Single Property
$AllUsers = Get-AzureResourcePaging -URL "https://graph.microsoft.com/v1.0/users?`$select=displayname" -AuthHeader $headersEX4
$AllUsers[0]






#Additonal Property, City
$AllUsers = Get-AzureResourcePaging -URL "https://graph.microsoft.com/v1.0/users?`$select=displayname,city" -AuthHeader $headersEX4
$AllUsers[0..10]








##################
#endregion Exercise 4
##################




##################
#region Exercise 5
##################

# Batching as its best, do not execute please -> Tenant restictions


#Authentication Exercise 5
#DON'T DO THIS AT HOME
$ClientIDEX5 = ""
$TenantIDEX5 = ""
$clientSecretEX5 = ""
#DON'T DO THIS AT HOME

#Authentication
#Connect to GRAPH API
$tokenBodyEX5 = @{  
    Grant_Type    = "client_credentials"
    Scope         = "https://graph.microsoft.com/.default"
    Client_Id     = $clientIdEX5
    Client_Secret = $clientSecretEX5
}
$token_ResponseEX5 = Invoke-RestMethod -Uri "https://login.microsoftonline.com/$tenantIDEX5/oauth2/v2.0/token" -Method POST -Body $tokenBodyEX5
$headersEX5 = @{
    "Authorization" = "Bearer $($token_ResponseEX5.access_token)"
    "Content-type"  = "application/json"
}






#Create a User
$NewUserBody = @"
{
    "mailNickname":  "Adam.Wagner",
    "surname":  "Wagner",
    "userPrincipalName":  "Adam.Wagner@au2mator.com",
    "displayName":  "Adam.Wagner",
    "givenName":  "Adam",
    "passwordProfile":  {
                            "password":  "P@ssw0rd",
                            "forceChangePasswordNextSignIn":  true
                        },
    "accountEnabled":  false,
    "jobTitle":  "DEVOPS DEMO"
}
"@


#$Out=Invoke-RestMethod -Body $NewUserBody -Headers $headersEX5 -Method Post -Uri "https://graph.microsoft.com/v1.0/users"



#Create a Group
$NewGroupBody = @"
{
    "description": "PS DevOps Group",
    "displayName": "DEVOPSDEMO",
    "groupTypes": [
        "Unified"
    ],
    "mailEnabled": false,
    "mailNickname": "DEVOPSDEMO",
    "securityEnabled": false
}
"@
#$Out=Invoke-RestMethod -Body $NewGroupBody -Headers $headersEX5 -Method Post -Uri "https://graph.microsoft.com/v1.0/groups"





#Get the New User
$Out = Invoke-RestMethod  -Headers $headersEX5 -Method GET -Uri "https://graph.microsoft.com/v1.0/users?`$filter=userPrincipalName eq 'Adam.Wagner@au2mator.com'"


#Get the New Group

$Out = Invoke-RestMethod  -Headers $headersEX5 -Method GET -Uri "https://graph.microsoft.com/v1.0/groups?`$filter=displayName eq 'DEVOPSDEMO'"




$JsonBody1 = @"
{
    "requests":  [
                     {
                         "id":  "1",
                         "method":  "POST",
                         "url":  "/users",
                         "headers":  {
                                         "Content-Type":  "application/json"
                                     },
                         "body":  {
                                "mailNickname":  "Bert.Wagner",
                                "surname":  "Wagner",
                                "userPrincipalName":  "Bert.Wagner@au2mator.com",
                                "displayName":  "Bert.Wagner",
                                "givenName":  "Bert",
                                "passwordProfile":  {
                                                    "password":  "P@ssw0rd",
                                                    "forceChangePasswordNextSignIn":  true
                                                },
                                "accountEnabled":  false,
                                "jobTitle":  "DEVOPS DEMO"
                                  }
                     },
                     {
                         "id":  "2",
                         "method":  "POST",
                         "url":  "/groups",
                         "headers":  {
                                         "Content-Type":  "application/json"
                                     },
                         "body":  {
                                "description": "PS DevOps Group",
                                "displayName": "DEVOPSDEMO2",
                                "groupTypes": [
                                    "Unified"
                                ],
                                "mailEnabled": false,
                                "mailNickname": "DEVOPSDEMO2",
                                "securityEnabled": false
                                  }
                     }
                 ]
}
)
"@





#$Out=Invoke-RestMethod -Headers $headersEX5  -Method POST -Uri "https://graph.microsoft.com/v1.0/`$batch" -Body $JsonBody1 


$Out.responses.body.error








# GAMETIME!!!!


##
#create Users
##


##FOREACH

#AUTHENTICATION !!!!!!



#$Firstnames = @("William","David","Richard","Joseph","Thomas","Charles","Christopher","Daniel","Matthew","Anthony","Donald","Mark","Paul","Steven","Andrew","Kenneth","Joshua","George","Kevin","Brian","Edward","Ronald","Timothy","Jason","Jeffrey","Ryan","Jacob","Gary","Nicholas","Eric","Stephen","Jonathan","Larry","Justin","Scott","Brandon","Frank","Benjamin","Gregory","Samuel","Raymond","Patrick","Alexander","Jack","Dennis","Jerry","Tyler","Aaron","Jose","Henry","Adam","Douglas","Nathan","Peter","Zachary","Kyle","Walter","Harold","Jeremy","Ethan","Carl","Keith","Roger","Gerald","Christian","Terry","Sean","Arthur","Austin","Noah","Lawrence","Jesse","Joe","Bryan","Billy","Jordan","Albert","Dylan","Bruce","Willie","Gabriel","Alan","Juan","Louis","Jonathan","Wayne","Roy","Ralph","Randy","Philip","Harry","Vincent","Bobby","Johnny","Logan","Mary","Patricia","Jennifer","Linda","Elizabeth","Barbara","Susan","Jessica","Sarah","Karen","Nancy","Lisa","Betty","Dorothy","Sandra","Ashley","Kimberly","Donna","Emily","Michelle","Carol","Amanda","Melissa","Deborah","Stephanie","Rebecca","Laura","Sharon","Cynthia","Kathleen","Helen","Amy","Shirley","Angela","Anna","Ruth","Brenda","Pamela","Nicole","Katherine","Virginia","Catherine","Christine","Samantha","Debra","Janet","Carolyn","Rachel","Heather","Maria","Diane","Emma","Julie","Joyce","Frances","Evelyn","Joan","Christina","Kelly","Martha","Lauren","Victoria","Judith","Cheryl","Megan","Alice","Ann","Jean","Doris","Andrea","Marie","Kathryn","Jacqueline","Gloria","Teresa","Sara","Janice","Hannah","Julia","Rose","Theresa","Grace","Judy","Beverly","Denise","Marilyn","Amber","Danielle","Brittany","Diana","Abigail")

$FirstnamesForeach = @("Joshua", "George", "Kevin")
$LastnamesForeach = @("Smith", "Johnson", "Williams", "Jones", "Brown", "Davis", "Miller", "Wilson", "Moore", "Taylor", "Anderson", "Thomas", "Jackson", "White", "Harris", "Martin", "Thompson", "Garcia", "Martinez", "Robinson", "Clark", "Rodriguez", "Lewis", "Lee", "Walker", "Hall", "Allen", "Young", "Hernandez", "King", "Wright", "Lopez", "Hill", "Scott", "Green", "Adams", "Baker", "Gonzalez", "Nelson", "Carter", "Mitchell", "Perez", "Roberts", "Turner", "Phillips", "Campbell", "Parker", "Evans", "Edwards", "Collins", "Stewart", "Sanchez", "Morris", "Rogers", "Reed", "Cook", "Morgan", "Bell", "Murphy", "Bailey", "Rivera", "Cooper", "Richardson", "Cox", "Howard", "Ward", "Torres", "Peterson", "Gray", "Ramirez", "James", "Watson", "Brooks", "Kelly", "Sanders", "Price", "Bennett", "Wood", "Barnes", "Ross", "Henderson", "Coleman", "Jenkins", "Perry", "Powell", "Long", "Patterson", "Hughes", "Flores", "Washington", "Butler", "Simmons", "Foster", "Gonzales", "Bryant", "Alexander", "Russell", "Griffin", "Diaz", "Hayes", "Myers", "Ford", "Hamilton", "Graham", "Sullivan", "Wallace", "Woods", "Cole", "West", "Jordan", "Owens", "Reynolds", "Fisher", "Ellis", "Harrison", "Gibson", "Mcdonald", "Cruz", "Marshall", "Ortiz", "Gomez", "Murray", "Freeman", "Wells", "Webb", "Simpson", "Stevens", "Tucker", "Porter", "Hunter", "Hicks", "Crawford", "Henry", "Boyd", "Mason", "Morales", "Kennedy", "Warren", "Dixon", "Ramos", "Reyes", "Burns", "Gordon", "Shaw", "Holmes", "Rice", "Robertson", "Hunt", "Black", "Daniels", "Palmer", "Mills", "Nichols", "Grant", "Knight", "Ferguson", "Rose", "Stone", "Hawkins", "Dunn", "Perkins", "Hudson", "Spencer", "Gardner", "Stephens", "Payne", "Pierce", "Berry", "Matthews", "Arnold", "Wagner", "Willis", "Ray", "Watkins")

$FirstnamesForeach.Count #4
$LastnamesForeach.Count #174
#696


$countForeach = 0
#create a foreach loop to create 200 users with every possible combination of Firstname and Lastname
foreach ($Firstname in $FirstnamesForeach) {
    foreach ($Lastname in $LastnamesForeach) {
        $Username = $Firstname + "." + $Lastname
        $Password = "P@ssw0rd"
        $Email = $Username + "@au2mator.com"

        #Create the User in Azure via Graph API
        $Body = @{
            'accountEnabled'    = $false
            'displayName'       = $Firstname + " " + $Lastname
            'mailNickname'      = $Username
            'givenName'         = $Firstname
            'surname'           = $Lastname
            'userPrincipalName' = $Email
            'jobTitle'          = "DEVOPS DEMO"
            'passwordProfile'   = @{
                'forceChangePasswordNextSignIn' = $true
                'password'                      = $Password
            }
        }
        $JsonBody = ConvertTo-Json $Body

        $Out = Invoke-RestMethod -Body $JsonBody -Headers $headersEX5 -Method Post -Uri "https://graph.microsoft.com/v1.0/users"
        $countForeach++
    }
}

#Result Foreach
$countForeach




#build a PowerShell Array with 200 international Lastnames
$FirstnamesBatch = @("Ronald", "Timothy", "Jason", "Paul")
$LastnamesBatch = @("Smith", "Johnson", "Williams", "Jones", "Brown", "Davis", "Miller", "Wilson", "Moore", "Taylor", "Anderson", "Thomas", "Jackson", "White", "Harris", "Martin", "Thompson", "Garcia", "Martinez", "Robinson", "Clark", "Rodriguez", "Lewis", "Lee", "Walker", "Hall", "Allen", "Young", "Hernandez", "King", "Wright", "Lopez", "Hill", "Scott", "Green", "Adams", "Baker", "Gonzalez", "Nelson", "Carter", "Mitchell", "Perez", "Roberts", "Turner", "Phillips", "Campbell", "Parker", "Evans", "Edwards", "Collins", "Stewart", "Sanchez", "Morris", "Rogers", "Reed", "Cook", "Morgan", "Bell", "Murphy", "Bailey", "Rivera", "Cooper", "Richardson", "Cox", "Howard", "Ward", "Torres", "Peterson", "Gray", "Ramirez", "James", "Watson", "Brooks", "Kelly", "Sanders", "Price", "Bennett", "Wood", "Barnes", "Ross", "Henderson", "Coleman", "Jenkins", "Perry", "Powell", "Long", "Patterson", "Hughes", "Flores", "Washington", "Butler", "Simmons", "Foster", "Gonzales", "Bryant", "Alexander", "Russell", "Griffin", "Diaz", "Hayes", "Myers", "Ford", "Hamilton", "Graham", "Sullivan", "Wallace", "Woods", "Cole", "West", "Jordan", "Owens", "Reynolds", "Fisher", "Ellis", "Harrison", "Gibson", "Mcdonald", "Cruz", "Marshall", "Ortiz", "Gomez", "Murray", "Freeman", "Wells", "Webb", "Simpson", "Stevens", "Tucker", "Porter", "Hunter", "Hicks", "Crawford", "Henry", "Boyd", "Mason", "Morales", "Kennedy", "Warren", "Dixon", "Ramos", "Reyes", "Burns", "Gordon", "Shaw", "Holmes", "Rice", "Robertson", "Hunt", "Black", "Daniels", "Palmer", "Mills", "Nichols", "Grant", "Knight", "Ferguson", "Rose", "Stone", "Hawkins", "Dunn", "Perkins", "Hudson", "Spencer", "Gardner", "Stephens", "Payne", "Pierce", "Berry", "Matthews", "Arnold", "Wagner", "Willis", "Ray", "Watkins")


$FirstnamesBatch.Count #4
$LastnamesBatch.Count #174
#696

#lets write a foreach to create every combination of $FirstnamesBatch and LastnamesBatch via Graph API and batch jobs
[hashtable]$Array = @{}
$BatchSize = 20
$BatchCount = 0
$Batch = @()
$countBatch = 0
foreach ($Firstname in $FirstnamesBatch) {
    foreach ($Lastname in $LastnamesBatch) {
        $BatchCount++
        $countBatch++

        $Username = $Firstname + "." + $Lastname
        $Email = $Username + "@au2mator.com"

        $Body = @{
            'accountEnabled'    = $false
            'displayName'       = $Username
            'mailNickname'      = $Username
            'givenName'         = $Firstname
            'surname'           = $Lastname
            'userPrincipalName' = $Email
            'jobTitle'          = "DEVOPS DEMO"
            'passwordProfile'   = @{
                'forceChangePasswordNextSignIn' = $true
                'password'                      = "P@ssw0rd"
            }
        }

        #$JsonBody = ConvertTo-Json $Body

        $Array.requests += @([ordered]@{ 
                id      = "$BatchCount";
                method  = "POST"
                url     = "/users"
                headers = @{"Content-Type" = "application/json" }
                body    = $Body
            })

        if ($BatchCount -eq $BatchSize -or $countBatch -eq ($FirstnamesBatch.Count * $LastnamesBatch.Count )) {
            $BatchJson = $Array | ConvertTo-Json -Depth 10
            $BatchResult = Invoke-RestMethod -Headers $headersEX5  -Method POST -Uri "https://graph.microsoft.com/v1.0/`$batch" -Body $BatchJson 
            $BatchCount = 0
            [hashtable]$Array = @{}
        }       
    }
}

#Result Batch
$countBatch







##################
#endregion Exercise 5
##################