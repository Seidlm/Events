
$User="your Uer"
$PW="your PW"
$ClientID = "your Client ID"

$resource = "https://graph.microsoft.com"

#https://to-do.microsoft.com/tasks/sharing?InvitationToken=3ogpq7Ey9cUBqQ3u1MG1UgO6OR1hWkGA18f6-G66_8AhY5TCn2tKpu5QdNGrkOnzE

$MicrosoftToDoListName = "Cloud8"
$title = "A New Task at Cloud8 Live Demo"
$importance = "normal" #Options: high, normal, low
$Body = "Thats my Body Text"

$DueDateTime="2022-09-29T22:00:00.0000000"
$DueTimeTzone="UTC"


#Connect to GRAPH API
$tokenBody = @{  
    Grant_Type = "password"  
    Scope      = "user.read%20openid%20profile%20offline_access"  
    Client_Id  = $clientId  
    username   = $User
    password   = $pw
    resource   = $resource
}   

$tokenResponse = Invoke-RestMethod "https://login.microsoftonline.com/common/oauth2/token" -Method Post -ContentType "application/x-www-form-urlencoded" -Body $tokenBody -ErrorAction STOP
$headers = @{
    "Authorization" = "Bearer $($tokenResponse.access_token)"
    "Content-type"  = "application/json"
}



#Get ID of List
$URLGetToDoLists = "https://graph.microsoft.com/v1.0/me/todo/lists?`$filter=displayName eq '$($MicrosoftToDoListName)'"
$Return = Invoke-RestMethod -Method GET -Headers $headers -Uri $URLGetToDoLists
$ListID = $Return.value.id



#Create a Task
$URLCreateTask = "https://graph.microsoft.com/v1.0/me/todo/lists/$ListID/tasks"
$JsonBody = @"
{
    "title":"$title",
    "importance":"$importance",
    "body":{
        "content":"$Body",
        "contentType":"text"
     },    
     "dueDateTime":{
         "dateTime":"$DueDateTime",
         "timeZone":"$DueTimeTzone"
        },
    "linkedResources":[
       {
          "webUrl":"https://techguy.at",
          "applicationName":"Browser",
          "displayName":"Techguy.at"
       }
    ]
}
"@

$Return = Invoke-RestMethod -Method POST -Headers $headers -Uri $URLCreateTask -Body $JsonBody
