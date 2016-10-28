script "lib_SivaSivaPortal"
--> MetaData
-
license: GPLv3
name: lib_SivaSivaPortal
type: library
version: 0.2

/*
The SivaSiva portal is a sel-contained group which presents a "contents view" of:

1) Top level portals to SivaSiva modules
2) Second level contents of individual SivaSiva modules

In general navigation terems we can consider the protal view as a giving a "book contents" style overview and springboard to material in individual modules.

Technicaly it is possible to have any number of levels, but we should try to avois any more thant 2 clicks before we navigate to actual module content.
The portals group is currently placed on one single card - the first card of the "sivasivahome" stack and uses an array stored in the model_SivaSiva.json file.
This data combines what was previously stored in a number of files scattered throughout the app.
It is still possible for individual modules to store their own module-specifig configuration data as before, but portal data shoul be stored in the model_SivaSiva.json file
and accessed via the handlers in the SivaSiva | Portal | Model section below.
*/


--> Variables
-
local LocalArray


--> Working On
-
command portal_DoRowLink rowName
   -- safe parsing only of accepted commands
   -- no dymanic execution of arbitrary code
   
   put portal_GetRowLinkArray (rowName) into linkArray
   put linkArray ["portal command"] into linkCommand
   put linkArray ["portal param"] into linkParam
   
   -- display_RowLink rowName
   
   switch linkCommand
      case "portal_Link"
         portal_Link linkParam
         break
      case "portal_Stack"
         portal_Stack linkParam
         break
      case "portal_Go"
         portal_Go linkParam
         break
      case "portal_Url"
         breakpoint
         break
      case "portal_LandscapeUrl"
         breakpoint
         break
   end switch
end portal_DoRowLink

command portal_Link portalName
   -- navigates to the "portal view" and displays the named portal
   put portal_GetHomeView() into portalView
   set the portal_Name of portalView to portalName
   portal_GoStack "Siva-Siva-App"
end portal_Link

command portal_GoName portalName
   portal_GoStack portalName
   return the result
end portal_GoName

command portal_GoStack stackName
   -- goes to the new stack
   -- closes the current stack
   -- safely ignores if we are alrady in the new stack
   
   put the short name of this stack into oStackName
   if oStackName = stackName then return oStackName
   
   go to stack stackName
   close stack oStackName
   return oStackName
end portal_GoStack

command portal_Go cardOrStackObject
   answer portal_Go
   /*
   This handler is for navigating to other card in stacks outside of the portal group in the sivasivahome stack.
   Because we have set the stackfiles we can simply go to the short name of the stack.
   The exception to this is the Siva-Siva-App" project home stack, which if it is closed menas that we loose the stackfiles capability!
   */
   
   put the short name of this stack into oStackName
   go cardOrStackObject in a new window
   put the result into goResult
   put the stack_Name of cardOrStackObject into newStackName
   if newStackName is oStackName then
      if the long id of cardOrStackObject = the long id of this card then
         -- the button or icon should proably be changed or disabled
      else
         -- going to a different card in the same stack
         -- answer "Not closing. Destination is the same stack."
      end if
   else
      if the environment is "Mobile" then
         close stack oStackName
      end if
   end if
   return goResult
end portal_Go


--> Portal | Navigation | API
-
/*
This section is for safe handlers that will be made available in the app through:

- user interaction (such as bookmarking)
- downloading json portal files that expose or deliver new book content
*/

command display_Log
   portal_GoStack "Log"
end display_Log

command sivasiva_GoHomePortal
   put the portal_View of stack "Siva-Siva-App" into portalView
   set the portal_Name of portalView to "home"
   portal_GoStack "Siva-Siva-App"
end sivasiva_GoHomePortal

command sivasiva_QueueContent btnObject, hiliteBoolean
   -- sivasiva_AddBookMark
   if the environment is "mobile" then
      answer mobileControls()
      answer the openstacks
   else
      answer "Does not work on desktop"
   end if
end sivasiva_QueueContent

command sivasiva_AddFavorites
   portal_DisplayBookmarks
end sivasiva_AddFavorites

command sivasiva_SettingsGear
   display_Log
end sivasiva_SettingsGear

command portal_Url someURL
   answer "Not done yet!"
end portal_Url

command portal_LandscapeUrl someURL
   answer "Not done yet!"
end portal_LandscapeUrl


--> SivaSiva | Portal | Row
-
function portal_ContainingRowName rowName, pSivasivaData
   -- here we only search topPortalNames
   put portal_ListTopNames() into topPortalNames
   put portal_GetData (pSivasivaData) into portalData
   repeat for each line topPortalName in topPortalNames
      put portalData [topPortalName]["rowData"] into rowData
      repeat for each key rowNum in rowData
         if rowData ["rowName"] = rowName then
            return topPortalName
         end if
      end repeat
   end repeat
   return empty
end portal_ContainingRowName

function portal_FindFromRowName rowName, pSivasivaData
   -- not used ???
   -- there could be more than one portalName that contains a rowName
   put portal_GetData (pSivasivaData) into portalData
   repeat for each key portalName in portalData
      put portalData [portalName]["rowData"] into rowData
      repeat for each key rowNum in rowData
         if rowData ["rowName"] = rowName then
            put portalName & CR after foundPortalNames
         end if
      end repeat
   end repeat
   delete char -1 of foundPortalNames
   sort foundPortalNames
   return foundPortalNames
end portal_FindFromRowName


--> Portal | List
-
function portal_ListTopNames
   -- we could hard wire it
   -- but here we consider rowNames of portal "home" to be the top level portals
   put portal_ListRowNames ("home") into homeRowNames
end portal_ListTopNames

function portal_ListNames pListHow, pSivasivaData
   switch pListHow
      case "folders"
         -- will not return portal names if we have other types of "module" in the "modules" folder
         put sivasiva_ListModuleFolders() into moduleNames
         break
      default
         put portal_GetData (pSivasivaData) into portalData
         put keys (portalData) into moduleNames
         sort moduleNames
   end switch
   return moduleNames
end portal_ListNames
    
function portal_ListRowNames portalName, pSivaSectionArray
   put portal_GetArray (portalName, pSivasivaData) into   moduleArray
   put moduleArray ["rowData"] into rowData
   put item 2 of the extents of rowData into maxNum
   repeat with keyNum = 1 to maxNum
      put rowData [keyNum]["rowName"] into portalLinkName
      put portalLinkName & CR after orderedPortalLinkNames
   end repeat
   delete char -1 of orderedPortalLinkNames
   return orderedPortalLinkNames
end portal_ListRowNames


--> SivaSiva | Portal | Model
-
function portal_GetRowLinkArray rowName
   --  We use the information stored in the sivasivaData array to retrieve the "link command" and "link param" from the rowName entry
   
   put portal_GetRowDictionary (pSivasivaData) into portalRowDictionary
   put portalRowDictionary [rowName]["link"] into linkArray
   return linkArray
end portal_GetRowLinkArray

command portal_SetRowLinkArray rowName, linkArray, pSivasivaData
   put portal_GetRowDictionary (pSivasivaData) into portalRowDictionary
   put linkArray into portalRowDictionary [rowName]["link"]
   portal_SetRowDictionary portalRowDictionary, pSivasivaData
end portal_SetRowLinkArray

function portal_GetRowData rowName, pSivasivaData
   put portal_GetRowDictionary (pSivasivaData) into portalRowDictionary
   put portalRowDictionary [rowName] into rowData
   return rowData
end portal_GetRowData

function portal_GetRowDictionary pSivasivaData
   sivasiva_FetchOrGetCached pSivasivaData
   put pSivasivaData ["portalRowDictionary"] into portalRowDictionary
   return portalRowDictionary
end portal_GetRowDictionary

command portal_SetRowDictionary portalRowDictionary, pSivasivaData
   sivasiva_FetchOrGetCached pSivasivaData
   put portalRowDictionary into pSivasivaData ["portalRowDictionary"]
   sivasiva_StoreData pSivasivaData
end portal_SetRowDictionary

function portal_GetArray portalName, pSivasivaData
   put portal_GetData (pSivasivaData) into portalData
   put portalData [portalName] into portalArray
   return portalArray
end portal_GetArray

function portal_GetData pSivasivaData
   sivasiva_FetchOrGetCached pSivasivaData
   put pSivasivaData ["portalData"] into portalData
   return portalData
end portal_GetData


--> Portal | Files
-
getprop scrolling_View
   put portal_GetHomeView() into portalView
   put the scrolling_View of portalView into scrollingView
   return scrollingView
end scrolling_View

getprop portal_View
   return portal_GetHomeView()
end portal_View

function portal_GetHomeView
   put portal_GetHomeStackPath() into portalHomeStackPath
   put the long id of control 1 of cd 1 of stack portalHomeStackPath into portalView
   -- put the portal_View of stack portalHomeStackPath into portalView
   return portalView
end portal_GetHomeView

function portal_GetHomeStackPath
   -- we will probably move the "portal home" from "sivasivahome" to the projects home stack "Siva-Siva-App"
   -- put the filename of stack "sivasivahome" into portalHomeStackPath
   put the filename of stack "Siva-Siva-App" into portalHomeStackPath
   return portalHomeStackPath
end portal_GetHomeStackPath
