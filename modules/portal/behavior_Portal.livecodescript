script "behavior_Portal"


global sConfigA


on preOpenStack
   ntinfo ("Portal: lockscreen is: " & (the lockscreen) )
   if isMobile() then    
      mobileSetAllowedOrientations "portrait,portrait upside down"
      --mobileSetFullScreenRectForOrientations "portrait,portrait upside down","0,0,414,736"
      --set the fullscreenmode of this stack to "showAll"
      set the fullscreenmode of this stack to empty
   end if
end preOpenStack


on openStack

   local tLastStack
   if the lockscreen <> true then lock screen
   
   
   put portal_GetLastStack() into tLastStack
   if not (tLastStack is "Siva-Siva-App" or tLastStack is empty) then
      switch tLastStack
         case "Siva-Siva-App"
            go card  "Home"
            break
         case "Surprise"
            go card  "Surprise"
            break
         case "Siva-Siva-Portal"
         case "pathtosiva"
         case "calendar"
         case "color-meditation"
         case "daily-lesson"
         case "lexicon"
            go to card "modulesList"
            send "LoadModulesList portal_GetModulesList()" to card "modulesList"  in 0 seconds
            break
         default
            go card  "mainNav"
      end switch
   end if
   if the lockscreen = true then unlock screen
   
   #unlock screen
end openstack


on closestack
   portal_SetLastStack "Siva-Siva-Portal"
end closestack



