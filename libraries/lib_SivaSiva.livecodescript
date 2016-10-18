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

--> Variables
-
local LocalArray


--> Working On
-
command portal_Go moduleName
   /*
   The moduleName "home" maps to the stack "sivasivahome" for obvious reasons
   Otherwise because we have set the stackfiles we could simply go to the short name of the stack
   */
   
   put sivasiva_GetModuleStackPath (moduleName) into moduleStackPath -- not strictly necessary
   log_Info ("Go to stack" && there is a stack moduleStackPath)
   
   put the short name of this stack into tOrigStack --jg: this avoids screen flashes
   go stack moduleStackPath in a new window
   if the environment is "development" then
      return moduleStackPath
   end if
   close stack tOrigStack
   return moduleStackPath
end portal_Go

command sivasiva_InitDefaults pOrientation -- mobile orientation setup
   if the environment is "mobile" then 
      set the fullscreenmode of this stack to "showAll" -- better for wider screens
      switch pOrientation
         case "landscape"
            mobileSetAllowedOrientations "landscape left,landscape right" -- lock to both landscape orientations
            break
         default -- "portrait"
            mobileSetAllowedOrientations "portrait,portrait upside down" -- lock to both portrait orientations
      end switch
   end if
end sivasiva_InitDefaults


--> Display
-
command sivasiva_DisplayHomePortalLink rowName, pSivaSectionArray
   sivasiva_DisplayPortalLink rowName, moduleName, pSivaSectionArray
   return the result
end sivasiva_DisplayHomePortalLink

command sivasiva_DisplayPortalLink rowName, moduleName, pSivaSivaData
   if pSivaSivaData is not an array then put sivasiva_FetchData() into pSivaSivaData
   put view_GetTemplateObject ("View|SivaSiva|Contents|Row") into rowTemplate
   
   sivasiva_SetPortalLinkInfo rowName, moduleName, pSivaSivaData, iconText, relativeImagefile, moduleFolder
  
   -- put moduleFolder & relativeImagefile into imageFile
   set the itemdelimiter to slash
   put item -1 of relativeImagefile into shortFile
   put sivasiva_PortalImageFile (shortFile) into imageFile
   
   if there is a file imageFile then
      set the image_File of rowTemplate to imageFile
   else
      put imageFile
      breakpoint
   end if
   set the title_Text of rowTemplate to iconText
   object_GoTo rowTemplate
   
   return pSivaSivaData
end sivasiva_DisplayPortalLink

command sivasiva_SetPortalLinkInfo rowName, sivaSivaData, @imageText, @shortImagefile
   put sivaSivaData ["portalRowDictionary"] into portalRowDictionary   
   put portalRowDictionary [rowName]["shortImagefile"] into shortImagefile
   put portalRowDictionary [rowName]["imageText"] into imageText
end sivasiva_SetPortalLinkInfo

command sivasiva_DisplayPortalHeader homeModueName, pHeaderView
   put portal_GetHeaderImageFile (homeModueName) into headerImageFile
   
   if exists (pHeaderView) is false then
      put view_GetTemplateObject ("View|SivaSiva|Image|Header") into pHeaderView
      object_GoTo pHeaderView
   end if
   set the image_File of pHeaderView to headerImageFile
end sivasiva_DisplayPortalHeader
