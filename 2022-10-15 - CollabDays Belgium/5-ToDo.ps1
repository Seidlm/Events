# Get List ID
# New ToDo in List

$User="yourUser"
$PW="yourPW"
$ClientID = "yourClientID"
$MSGRAPHAPI_BaseURL="https://graph.microsoft.com/v1.0"
$resource = "https://graph.microsoft.com"


#Variables
$MicrosoftToDoListName = "CollabDays2022"
$title = "A New Task at CollabDays Belgium Live Demo"
$importance = "high" #Options: high, normal, low
$Body = "Thats my Body Text"
$DueDateTime="2022-10-15T22:00:00.0000000"
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

$token_Response = Invoke-RestMethod "https://login.microsoftonline.com/common/oauth2/token" -Method Post -ContentType "application/x-www-form-urlencoded" -Body $tokenBody -ErrorAction STOP
$token_Header = @{
    "Authorization" = "Bearer $($token_Response.access_token)"
    "Content-type"  = "application/json"
}



#Get ID of List
$GetToDoList_Params = @{
    Method = "Get"
    Uri    = "$MSGRAPHAPI_BaseURL/me/todo/lists?`$filter=displayName eq '$($MicrosoftToDoListName)'"
    header = $token_Header
 }
 
 $GetToDoList_Result = Invoke-RestMethod @GetToDoList_Params
 $ListID = $GetToDoList_Result.value.id




#Create a Task
$CreateToDo_Body = @"
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


$CreateToDo_Params = @{
    Method = "POST"
    Uri    = "$MSGRAPHAPI_BaseURL/me/todo/lists/$ListID/tasks"
    header = $token_Header
    body   = $CreateToDo_Body
 }
 
 $CreateToDo_Result = Invoke-RestMethod @CreateToDo_Params
