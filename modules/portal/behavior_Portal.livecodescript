script "behavior_Portal"

global sConfigA

on preOpenStack
   ntinfo ("Portal: lockscreen is: " & (the lockscreen) )
   if isMobile() then    
      mobileSetAllowedOrientations "portrait,portrait upside down"
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

# set a hidden preference of disk to call of 5 - 10
# brand images. We will make it generic and save just integer


function getUserPreferences pPref
   put getPref ("preferences/modules/portal") into aPortalPreferences
   put aPortalPreferences[pPref] into pPref
   return pPref
end getUserPreferences

command saveUserPrefs sBrandImageNumber
   setPref "preferences/modules/portal/brandImageNumber", sBrandImageNumber
end saveUserPrefs

on closestack
   portal_SetLastStack "Siva-Siva-Portal"
end closestack



