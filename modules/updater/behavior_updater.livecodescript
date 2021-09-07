script "behavior_updater"
on preOpenCard 
   if the environment is not "development" then
      hide stack "Siva-Siva-App"
   end if  
   set the width of field "status" to the width of this card 
   set the loc of field "status" to the (the width of this card /2, the height of this card/2)
   set the loc of widget "Spinner" to the loc of field "status"
   set the bottom of widget "Spinner" to the top of field "status" - 20
   hide widget "spinner"
end preOpenCard

on errorDialog pExecutionError, pParseError
   repeat for each line x in pExecutionError
      log x
   end repeat
end errorDialog

private on log pText
   put pText
end log


command st pText
   put pText into field "status"
   log pText
end st

on openCard
   st "Checking for updates..."
   setDownloadStatusCallback "updateUI", the long id of this stack
   show widget "spinner"
   st "Downloading updates..."
   downloadAssets
end openCard

on updateUI pStatus
   switch word 1 of pStatus
      case "loading"
         st ("Downloading:" && floor((word 2 of pStatus / word 3 of pStatus) * 100) &"%")
         break
      case "expanding"
         st ("Expanding:" && floor((word 2 of pStatus / word 3 of pStatus) * 100) &"%")
         break
      case "downloaded"
         st "Expanding assets..."
         verifyAndExpandAssets
         break
      case "expanded"
         hide widget "spinner"
         send "continue_AppInitialization" to card "InitializeApp" of stack "Siva-Siva-App"
         break
      case "contacted"
      case "requested"
         st word 1 of pStatus
         break
      case "error"
         st "Error"
         hide widget "Spinner" of card id 1002 of me
         break
      default
         log "unknown status"
         log pStatus
         repeat for each line x in the executionContexts
            log x
         end repeat
         break
   end switch
end updateUI
