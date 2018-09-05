script "behavior_ViewBrowser"
Local sStartLoadTime,sTimePassed,sLoadSuccessFlag,

# BUG iOS does not respond with this command  "browserDocumentLoadBegin"
# the loading Spinner and cancel command remain of screen.
# it work on android. This is need in case the URL does load
# and the user wants leave the connection.

on browserDocumentLoadBegin pURL
   hide field "cancel" 
   hide widget "Spinner"
   show widget "Body"
   show group "footer"
end browserDocumentLoadBegin

on browserDocumentLoadComplete pURL
   put "true" into sLoadSuccessFlag
   browser_SetLastURL pURL
   journal_AddEntry
end browserDocumentLoadComplete
