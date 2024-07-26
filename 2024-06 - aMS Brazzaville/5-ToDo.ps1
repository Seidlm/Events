#https://learn.microsoft.com/en-us/graph/api/todotasklist-post-tasks?view=graph-rest-1.0&tabs=http
# Get List ID
# New ToDo in List


#DON'T DO THIS AT HOME
$ClientID = "your Client ID"
$TenantID="your Tenant ID"
$clientSecret = "Your Secret"
#DON'T DO THIS AT HOME


$MSGRAPHAPI_BaseURL="https://graph.microsoft.com/v1.0"


#Variables
$MicrosoftToDoListName = "aMSBrazzaville"
$title = "A New Task at aMSBrazzaville 2024 Live Demo"
$importance = "high" #Options: high, normal, low
$Body = "Thats my Body Text"
$DueDateTime="2024-06-26T22:00:00.0000000"
$DueTimeTzone="UTC"

$User = "michael.seidl@au2mator.com"




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
  
  #########################################


#Get ID of List
$GetToDoList_Params = @{
    Method = "Get"
    Uri    = "$MSGRAPHAPI_BaseURL/users/$User/todo/lists?`$filter=displayName eq '$($MicrosoftToDoListName)'"
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
    Uri    = "$MSGRAPHAPI_BaseURL/users/$User/todo/lists/$ListID/tasks"
    header = $token_Header
    body   = $CreateToDo_Body
 }
 
 $CreateToDo_Result = Invoke-RestMethod @CreateToDo_Params
