script "lib_SivaSiva"
--> MetaData
-
license: GPLv3
name: lib_SivaSiva
type: library
version: 0.2


/*
This library by David was for handlers dealing with generic global Siva-Siva-App functionality such as displaying portal images.

Currently these temporary handlers display portal data in the portal template stacks:
-  View|SivaSiva|Contents|Row
-  View|SivaSiva|Image|Header

BR: this lib was later superceded by the SivaSiva Portal script that david wrote, but holds some functions relating to gloval look and feel
WE should make more use of this script so that individual modules are not reinventing the wheel.No
Note useful things liek showing the devices status bar or not.

Today this lib is "open for use"   for global common things that really belong in any specific library. 

the previous init script was extracted and only does init functions
the Portal stack has behaviors relating to building the portal view.

the lib_SivaSivaPortal also has the the complete portal navigation API, referred to below.
*/


--> Sivasiva
--

local sDownloadNewContent

/*
BR, June 6, 2017: some function should trigger the app to fetch any new content that can be legally download
with requiring a review process by Apple.  This could be on initial installation  and also for discreet updates to 
specific, non-executable, security save content.

Talk with Andre about methods.  
We probably put a 
        sivasiva_content.config
file on the server.
Some JSON with info on what to download
Fetch this somewhere in the app 
if the JSON tells us we have now content,
then proceed.  
OR use a simple ping file like

new-siva-content.txt  

with single word "true" or "false"

check this first.

*/

command sivasiva_checkNewContent
   # Ping server for updates?
   put "false"  into pBool # for now
   put pBool into sDownloadNewContent 
end sivasiva_checkNewContent

#use this in appropriate places where you may want updates later
# e.g. About this App; Privacy Policy are common use cases.
# 
function sivasiva_IsThereNewContent  
   return sDownloadNewContent
end sivasiva_IsThereNewContent

command sivasiva_InitOrientation orientationType
   -- try to avoid and specifically set fullscreenmode and mobile_SetAllowedOrientation for each module
   
   if the environment is not "mobile" then
      return false
   else
      set the fullscreenmode of this stack to "showAll" -- better for wider screens
      mobile_SetAllowedOrientation orientationType
   end if
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
-- BR we should probably move all the nav function here from the  lib_

/*
This section is for default navigation handlers.
They can be overridden in a stack by placing copies of these handlers in the stack
for instance on the card
*/

command sivasiva_GoHomePortal
   portal_Link "home"
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
 
function pingServer
   # call from any where to inform user and disable activities
   # that require internet access to our server or any the external service
   put url "https://www.himalayanacademy.com/ping.txt" into tOnline 
    return tOnLine
end pingServer

command sivasiva_SetStatusBarVis visBoolean
        if visBoolean then
            mobileShowStatusBar
        else
            mobileHideStatusBar
        end if        
 end sivasiva_SetStatusBarVis
    
