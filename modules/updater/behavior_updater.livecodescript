script "behavior_updater"
on preOpenCard 
   
   
   if the environment is not "development" then
      hide stack "Siva-Siva-App"
   end if  
   
   hide widget "Spinner"
end preOpenCard

on errorDialog pExecutionError, pParseError
   repeat for each line x in pExecutionError
      log x
   end repeat
end errorDialog

on log pText
   if the environment is not "development" then
      put pText
   else 
      pass log
   end if
end log


command st pText
   put pText into field "status"
   --   log pText
end st

on openCard
   
   local tStatus, tSpinner, tImage
   
   #  UI responsive
   --breakpoint
   put the long id of fld "status"  into tStatus
   put the long id of widget "Spinner"  into tSpinner
   
  
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
         send "continue_AppInitialization" to card "InitializeApp" of stack "Siva-Siva-App" in 50 millisecs
         close this stack
         break
      case "contacted"
      case "requested"
         st word 1 of pStatus
         break
      case "error"
         put pStatus
         st word 2 to -1 of pStatus
         hide widget "Spinner" of card id 1002 of me
         break
      case "expanderr"
         log "error expanding assets."
         st "Error, will try again in couple seconds."
         send "downloadAssets" to me in 3 seconds
         exit updateUI 
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
