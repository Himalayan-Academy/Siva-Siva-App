script "lib_SivaSiva"
--> MetaData
-
license: GPLv3
name: lib_SivaSiva
type: library
version: 0.2

/*
This library is for handlers dealing with generic Siva-Siva-App functionality such as displaying portal images.

Currently these temporary handlers display portal data in the portal template stacks:
-  View|SivaSiva|Contents|Row
-  View|SivaSiva|Image|Header
*/


--> Sivasiva
-
command sivasiva_InitOrientation orientationType
   -- try to avoid and specifically set fullscreenmode and mobile_SetAllowedOrientation for each module
   
   if the environment is not "mobile" then return false
   set the fullscreenmode of this stack to "showAll" -- better for wider screens
   mobile_SetAllowedOrientation orientationType
end sivasiva_InitOrientation

command mobile_SetAllowedOrientation orientationType
   if the environment is not "mobile" then return empty
   
   switch orientationType
      case "portrait"
         put "portrait,portrait upside down" into allowedOrientations
         break
      case "landscape"
         put "landscape left,landscape right" into allowedOrientations
         break
      default -- allow all, ignoring face up/down
         put "portrait,portrait upside down,landscape left,landscape right" into allowedOrientations
   end switch
   mobileSetAllowedOrientations allowedOrientations
   return allowedOrientations
end mobile_SetAllowedOrientation

# missing function used by many modules and scripts
# BR: added back in 2016-12-06
function isMobile
	return the environment is "mobile"
end isMobile

--> Portal | Navigation | API
-
/*
This section is for default navigation handlers.
They can be overridden in a stack by placing copies of these handlers in the stack
for instance on the card
*/

command sivasiva_GoHomePortal
   portal_Link "home"
   -- put the portal_View of stack "Siva-Siva-App" into portalView
   -- set the portal_Name of portalView to "home"
   -- portal_GoStack "Siva-Siva-App"
end sivasiva_GoHomePortal

command sivasiva_QueueContent btnObject, hiliteBoolean
   -- sivasiva_AddBookMark
   if the environment is "mobile" then
      dispatch "sivasiva_ToggleOrientation" to the target
   else
      dispatch "sivasiva_ToggleOrientation" to the target
   end if
end sivasiva_QueueContent

command sivasiva_AddFavorites
   portal_DisplayBookmarks
end sivasiva_AddFavorites

command sivasiva_SettingsGear
   display_Log
end sivasiva_SettingsGear

command display_Log
   portal_GoStack "Log"
end display_Log
