#https://learn.microsoft.com/en-us/graph/api/user-sendmail?view=graph-rest-1.0&tabs=http

# Send Mail via Graph API

#DON'T DO THIS AT HOME
$ClientID = "your Client ID"
$TenantID="your Tenant ID"
$clientSecret = "your Secret"
#DON'T DO THIS AT HOME

$MSGRAPHAPI_BaseURL="https://graph.microsoft.com/v1.0"

#Variables
$MailSender = "michael.seidl@au2mator.com"
$Recipient = "michael.seidl@au2mator.com"


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



#Send Mail    
$MailSend_Body = @"
                    {
                        "message": {
                          "subject": "Hello World from Microsoft Graph API",
                          "body": {
                            "contentType": "HTML",
                            "content": "This Mail is sent via Microsoft <br>
                            <br>
                            <br>
                            GRAPH <br>
                            API<br>
                            <br>
                            <br>
                            Azure Zero to Hero
                            <br>
                            <br>
                            <br>
                            <br>
                            <br>
                            "
                          },
                          "toRecipients": [
                            {
                              "emailAddress": {
                                "address": "$Recipient"
                              }
                            }
                          ]
                        },
                        "saveToSentItems": "false"
                      }
"@

$MailSend_Params = @{
  Method = "POST"
  Uri    = "$MSGRAPHAPI_BaseURL/users/$MailSender/sendMail"
  header = $token_Header
  body   = $MailSend_Body
}



Invoke-RestMethod @MailSend_Params