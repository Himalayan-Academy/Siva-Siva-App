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
   lock screen
   local tLastStack
   set the acceleratedRendering of this stack to true
   put portal_GetLastStack() into tLastStack
   switch tLastStack
      case "Siva-Siva-App"
      case empty
         go card  "Home"
         break
      case "Surprise"
         go card  "Surprise"
         break
      default
         go card "Home"
   end switch
   unlock screen
end openstack


#### deprecated nav
--on openStack
--   local tLastStack
--   set the acceleratedRendering of this stack to true
--   put portal_GetLastStack() into tLastStack
--   --if not (tLastStack is "Siva-Siva-App" or tLastStack is empty) then
--   switch tLastStack
--      case "Siva-Siva-App"
--      case empty
--         go card  "Home"
--         break
--      case "Surprise"
--         go card  "Surprise"
--         break
--      case "Siva-Siva-Portal"
--      case "pathtosiva"
--      case "calendar"
--      case "color-meditation"
--      case "daily-lesson"
--      case "lexicon"
--         go to card "modulesList"
--         send "LoadModulesList portal_GetModulesList()" to card "modulesList" -- in 0 seconds
--         break
--      default
--         go card  "mainNav"
--   end switch
--   --end if
--end openstack

# set a hidden preference of disk to call of 5 - 10
# brand images. We will make it generic and save just integer


function getUserPreferences pPref
   local tPortalPreferences, tPref
   put getPref ("preferences/modules/portal") into tPortalPreferences
   put tPortalPreferences[pPref] into tPref
   return tPref
end getUserPreferences

on closestack
   portal_SetLastStack "Siva-Siva-Portal"
end closestack



