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
   set the acceleratedRendering of this stack to false
end openstack

function getUserPreferences pPref
   local tPortalPreferences, tPref
   put getPref ("preferences/modules/portal") into tPortalPreferences
   put tPortalPreferences[pPref] into tPref
   return tPref
end getUserPreferences

on closestack
      portal_SetLastStack "Siva-Siva-Portal"
end closestack




