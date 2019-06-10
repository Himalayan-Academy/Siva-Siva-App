Script "stack_Siva-Siva-Portal_"

/*
# Name: stack "Siva-Siva-Portal"
# ID: stack "Siva-Siva-Portal"
*/


global sConfigA


on preOpenStack
   
   ntinfo ("Portal: lockscreen is: " & (the lockscreen) )
   if isMobile() then    
      mobileSetAllowedOrientations "portrait,portrait upside down"
      mobileSetFullScreenRectForOrientations "portrait,portrait upside down","0,0,414,736"
      set the fullscreenmode of this stack to "showAll"
   end if
   
   if not (portal_GetLastStack() is "Siva-Siva-App" or  Portal_GetLastStack() is empty) then
      switch Portal_GetLastStack()
         case "Siva-Siva-App"
            go card  "Home"
            break
         case "Surprise"
            go card  "Surprise"
            break
         case "view_SivaSivaBrowser"
         case "view_BrowserLandscape"
         case "pathtosiva"
         case "calendar"
         case "color-meditation"
         case "daily-lesson"
         case "lexicon"
            lock screen
            go to card "modulesList"
            --dispatch loadModulesList to group "globalPortalMap" of card "modulesList"  with portal_GetModulesList() 
            send "LoadModulesList portal_GetModulesList()" to card "modulesList"  in 0 seconds
            unlock screen
            break
            
         default
            go card  "mainNav"
      end switch
   end if
   
end preOpenStack

on closestack
   portal_SetLastStack "Siva-Siva-Portal"
end closestack



