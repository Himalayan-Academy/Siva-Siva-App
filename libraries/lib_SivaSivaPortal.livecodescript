script "lib_SivaSivaPortal"
script "lib_SivaSivaPortal"
--> MetaData
-
license: GPLv3
name: lib_SivaSivaPortal
type: library
version: 0.2
Original Script by David Bovill

/*
The SivaSiva portal is a self-contained group which presents a "contents view" of:

1) Top level portals to SivaSiva modules
2) Second level contents of individual SivaSiva modules

In general navigation terems we can consider the portal view as a 
giving a "book contents" style overview and springboard to material in individual modules.

Technicaly it is possible to have any number of levels, but we should try to avois any more thant 2 clicks before we navigate to actual module content.
The portals group is currently placed on one single card - the first card of the "sivasivahome" stack and uses an array stored in the model_SivaSiva.json file.
This data combines what was previously stored in a number of files scattered throughout the app.
It is still possible for individual modules to store their own module-specifig configuration data as before, but portal data shoul be stored in the model_SivaSiva.json file
and accessed via the handlers in the SivaSiva | Portal | Model section below.

BR: Aside from handling the layout of the portal stack, this script also controls
the general flow of navigation across the entire app, where users are going from one module to another
Modules handle internal navigation across their own cards in the same stack.
Key handlers for global navigaiton are the Portal_GoStack, Portal_SetCurrentStack, portal_GetLastStack
Which are called to track movement across modules so that "Back" will return to the last viewed  view/stack
*/


--> Variables
-
local LocalArray, sCurrentPortal,sLastStack,sLastLinkTitle


--> Working On
-
function portal_GetLinkUrl portalName, pSivasivaData
   put portal_GetArray (portalName, pSivasivaData) into portalArray
   put portalArray ["portalColour"] into portalColour
   if portalColour is empty then return "255,241,208"
   return portalColour
end portal_GetLinkUrl

command portal_SetLinkUrl portalName, portalColour, pSivasivaData
   put portal_GetArray (portalName, pSivasivaData) into portalArray
   put portalColour into portalArray ["portalColour"]
   portal_SetArray portalName, portalArray, pSivasivaData
end portal_SetLinkUrl



command portal_DoRowLink rowName
   -- safe parsing only of accepted commands
   -- no dymanic execution of arbitrary code
   portal_SetLastLinkTitle rowName
   put portal_GetRowLinkArray (rowName) into linkArray
   put linkArray ["portal command"] into linkCommand
   put linkArray ["portal param"] into linkParam
   
   -- display_RowLink rowName
   
   switch linkCommand
      case "portal_Link"
         portal_Link linkParam
         break
      case "portal_GoStack"  
         portal_GoStack linkParam
         break
      case "portal_Go"
         portal_Go linkParam
         break
      case "portal_GoUrl"
         portal_GoUrl linkParam
         break
      case "portal_GoLandscapeUrl"
         portal_GoLandscapeUrl linkParam
         break
      case "portal_LaunchUrl" # invoke external browser
         portal_LaunchURL linkParam
         break
   end switch
end portal_DoRowLink

command portal_GoUrl someURL,pJournalLabel
   #the Browser is called from various contexts
   # we need to know where we came from in order to 
   # handle returning to the context properly.
   put the short name of this stack into oStackName
   portal_SetCurrentStack(oStackName)
   portal_GoStack "view_SivaSivaBrowser"
   set the browser_URL of stack "view_SivaSivaBrowser" to someURL
   # we are setting the journal here, but sometimes the call will be made
   # from another journal entry which is "resuming"  from a different activity 
   # than the simple web Portal
   # we need to later resolve the various scenarios
   # for now we call it simple "Web"
   if pJournalLabel is empty then 
      # dev has not passed anything, so probably coming from portal
      put sLastLinkTitle into tWebPageTags
   else
      put pJournalLabel into tWebPageTags
   end if
   put someURL into pData["weburl"]
   Journal_RecordEntry "view_SivaSivaBrowser","Web", pData, tWebPageTags
end portal_GoUrl

command portal_LaunchUrl someURL
   # leave Siva Siva app and open the native web app on the device
    launch url someURL    
end portal_LaunchUrl

command portal_GoLandscapeUrl someURL
   set the browser_URL [true] of stack "view_SivaSivaBrowser" to someURL
   portal_GoStack "view_SivaSivaBrowser"
end portal_GoLandscapeUrl

command portal_Link portalName
   
   -- navigates to the "portal view" and displays the named portal
   lock screen
   sivasiva_InitOrientation "portrait" ## Needed if we are returning from a landscape stack
   if not (sLastStack="Siva-Siva-App") then 
      # called from a module and not the portal stack
      close stack sLaststack
      portal_GoStack "Siva-Siva-Portal" 
   end if
   # otherwise we are already in the portal stack
   # Either case we have to build the view:
   
   put portal_GetHomeView() into portalView
   
   portal_SetCurrent portalName
   portal_SetCurrentStack "Siva-Siva-Portal"
   set the portal_Name of portalView to portalName
   unlock screen
   set the logo_Faded of portalView to true
end portal_Link

command portal_SetCurrent portalName
   put portalName into sCurrentPortal   
end portal_SetCurrent

function portal_GetCurrent
    # BR: Support for tracking the portal from which
    # a module was launched from   
    return sCurrentPortal
end portal_GetCurrent

command portal_SetCurrentStack stackName
    put stackName into sLastStack  
end portal_SetCurrentStack

function portal_GetLastStack
   # BR: Support for tracking the stack from which
   # a module was launched from   so we can go back
   return sLastStack
end portal_GetLastStack



command  portal_SetLastLinkTitle rowName
   put rowName into sLastLinkTitle # for use in Journal and other context to show user a label
end portal_SetLastLinkTitle

function portal_GetLastLinkTitle
   return sLastLinkTitle
end portal_GetLastLinkTitle

-----------------------------------------------------------
-- portal_GoStack
-- DESCRIPTION
--  This is the main navigation command that switch stacks on demand
--   it is set to close all stacks other than the loader stack
--    so you will need to be careful about addressing scripts in the hierarchy if the 
--    stack is already closed. 
--  to "go back" this handler set the last module traversed by the user expect for 
-- SivaSivaApp, Journal, and Browser (unless from Journal)
-- PARAMETERS
-- this can be simply the short name of the stack  or a string like
-- "card 1 of  stack  tSomeStackName" 
-- CHANGES:  2016-08-01 David Bovil -- created
-- 2017-04/05 Brahmanathaswami, added more robust  code for going back.
--------------------------------------------------------------

command portal_GoStack cardOrStackObject 
	--  stackName
	# save where we are coming from locally
	put the short name of this stack into oStackName
	put "Siva-Siva-App,Journal,view_SivaSivaBrowser"  into tNoGoBackStacks
	if not  (oStackName is among the items of tNoGoBackStacks) then
		portal_SetCurrentStack oStackName
	end if

	if not  (oStackName= "Siva-Siva-App") then  
		# always close.; all stack should be set to remove window and destroy on close
		# this is required to function properly o Android 
		close stack oStackName  
	end if
	go  cardOrStackObject  # e.g   go "gems" (or this string)  go card 3 of "gems" 
end portal_GoStack

command portal_RemoveStack oStackName
	if stackName <> "Siva-Siva-Portal" then
	close stack oStackName
	end if    
end portal_RemoveStack

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

function portal_GetHeaderImage portalName, pSivasivaData
   put portal_GetArray (portalName, pSivasivaData) into portalArray
   put portalArray ["headerImage"] into shortHeaderImageFile
   return shortHeaderImageFile
end portal_GetHeaderImage

command portal_SetHeaderImage portalName, shortHeaderImageFile, pSivasivaData
   put portal_GetArray (portalName, pSivasivaData) into portalArray
   put shortHeaderImageFile into portalArray ["headerImage"]
   portal_SetArray portalName, portalArray, pSivasivaData
end portal_SetHeaderImage

function portal_GetBackgroundColour portalName, pSivasivaData
   put portal_GetArray (portalName, pSivasivaData) into portalArray
   put portalArray ["portalColour"] into portalColour
   if portalColour is empty then return "255,241,208"
   return portalColour
end portal_GetBackgroundColour

command portal_SetBackgroundColour portalName, portalColour, pSivasivaData
   put portal_GetArray (portalName, pSivasivaData) into portalArray
   put portalColour into portalArray ["portalColour"]
   portal_SetArray portalName, portalArray, pSivasivaData
end portal_SetBackgroundColour

function portal_GetArray portalName, pSivasivaData
   put portal_GetData (pSivasivaData) into portalData
   put portalData [portalName] into portalArray
   return portalArray
end portal_GetArray

command portal_SetArray portalName, portalArray, pSivasivaData
   put portal_GetData (pSivasivaData) into portalData
   put portalArray into portalData [portalName]
   portal_SetData portalData, pSivasivaData
end portal_SetArray

function portal_GetData pSivasivaData
   sivasiva_FetchOrGetCached pSivasivaData
   put pSivasivaData ["portalData"] into portalData
   return portalData
end portal_GetData

command portal_SetData portalData, pSivasivaData
   sivasiva_FetchOrGetCached pSivasivaData
   put portalData into pSivasivaData ["portalData"]
   sivasiva_StoreData pSivasivaData
end portal_SetData


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
    #BR -- David had set this to "control 1" but it needs to be set to Control 2 which is the 
    # group above the background object... why we can't jus declare the name of the4
    # group is beyond me... but it broke after I put a large background grc on layer 1
   put the long id of control 2 of cd 1 of stack portalHomeStackPath into portalView
   -- put the portal_View of stack portalHomeStackPath into portalView
   return portalView
end portal_GetHomeView

function portal_GetHomeStackPath
   -- we will probably move the "portal home" from "sivasivahome" to the projects home stack "Siva-Siva-Portal"
   -- put the filename of stack "sivasivahome" into portalHomeStackPath
   put the filename of stack "Siva-Siva-Portal" into portalHomeStackPath
   return portalHomeStackPath
end portal_GetHomeStackPath
