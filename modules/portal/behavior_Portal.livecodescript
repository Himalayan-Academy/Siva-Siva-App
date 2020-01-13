script "behavior_Portal"
global sConfigA

on preOpenStack
   ntinfo ("Portal: lockscreen is: " & (the lockscreen) )
   if isMobile() then    
      mobileSetAllowedOrientations "portrait,portrait upside down"
      set the fullscreenmode of this stack to empty
      iphoneSetAudioCategory "playback" 
   end if
end preOpenStack

on openStack
   set the acceleratedRendering of this stack to true
end openstack

# set a hidden preference of disk to call of 5 - 10
# brand images. We will make it generic and save just integer

function getUserPreferences pPref
   local tPortalPreferences, tPref
   put getPref ("preferences/modules/portal") into tPortalPreferences
   put tPortalPreferences[pPref] into tPref
   return tPref
end getUserPreferences

on closestack
   if the short name of this card <> "Surprise" then
      portal_SetLastStack "Siva-Siva-Portal"
   end if
end closestack




