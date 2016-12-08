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
command sivasiva_InitOrientation pOrientation
   -- mobile orientation setup
   if the environment is not "mobile" then return false
   
   set the fullscreenmode of this stack to "showAll" -- better for wider screens
   switch pOrientation
      case "landscape"
         mobileSetAllowedOrientations "landscape left,landscape right" -- lock to both landscape orientations
         break
      default -- "portrait"
         mobileSetAllowedOrientations "portrait,portrait upside down" -- lock to both portrait orientations
   end switch
   return true
end sivasiva_InitOrientation

# missing function used by many modules and scripts
# BR: added back in 2016-12-06
function isMobile
	 if the environment is not "mobile" then 
		 return false
	 else
		 return true
	 end if
end isMobile


