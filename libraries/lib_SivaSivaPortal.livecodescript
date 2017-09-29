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

we Realy should separate all thehandler pertaining to the "views" and move them to a navigation library.
*/ 


--> Variables
-
local LocalArray, sCurrentPortal,sLastStack,sLastLinkTitle



------------- Navigation section -------------------
# BR: this whole set of handlers probably should move to a separate lib dedicated to navigation
# or all the way "up" to the primary back script: lib_SivaSiva
# Functions related to presentation that have been deprecated.
# and moved to the end  for save keeping

------------------------------------------------------


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
   # save where we are coming from locally
   put the short name of this stack into oStackName
   put "Siva-Siva-App,Journal,view_SivaSivaBrowser"  into tNoGoBackStacks
   if (sLastStack="Journal") AND (cardOrStackObject <> "Journal") then 
      # it means we are launching activity and we are not actually going
      # to the view the journal, in which case we have to be sure it closes
      put "Journal" into oStackName
   end if
   if (not  (oStackName is among the items of tNoGoBackStacks) ) then
      portal_SetCurrentStack oStackName
   end if
   # cannot pass quotes to these strings or you willl
   # break the JSON, BR added utilities section to lib_SivaSiva
   
   put removeQuotes(cardOrStackObject) into pTrackdata["contentTarget"]
   # user clicks on a portal link but is going out to content
   
   if  oStackName is "Siva-Siva-Portal" then 
      put "navigation/topindex" into pAction
   else 
      put "navigation/goContent" into pAction
   end if
   put oStackName into pTrackData["exitFrom"]
   tracking_RecordActivity "Portal", pAction, pTrackdata
   
   go  cardOrStackObject  # e.g   go "gems" (or this string)  go card 3 of "gems"   
   wait 100 milliseconds with messages  
   close stack oStackName   
   
end portal_GoStack

command portal_Link portalName
   put portalName into pTrackdata["contentTarget"]
   # our navigation will change in the future, but this is still the same thing
   # user is moving from  TOC, or Index, or Map to another
   # not actually interacting with content at all hyet.
   tracking_RecordActivity "Portal", "navigation/topindex", pTrackdata
   -- navigates to the "portal view" and displays the named portal
   sivasiva_InitOrientation "portrait" ## Needed if we are returning from a landscape stack
   lock screen
   if not (sLastStack="Siva-Siva-Portal") then 
      # called from a module and not the portal stack
      put format ("card \"%s\" of stack \"Siva-Siva-Portal\"",portalName) into tPortalTarget
            portal_GoStack tPortalTarget
   else
      go card portalName
   end if
   
   
   portal_SetCurrent portalName
   portal_SetCurrentStack "Siva-Siva-Portal"
   
   unlock screen
   # the following introduces a non-responsive phase while the 
   # so we are trying "very fast" 
  --show button "home-logo"  
 --hide button "home-logo" with visual effect dissolve very fast
   news_Fetch
   
   # Davids  old calls to build dynamically
   # otherwise we are already in the portal stack
   # Either case we have to build the view:
   -- put portal_GetHomeView() into portalView # deprecated: portals are pre-built
   -- set the portal_Name of portalView to portalName  #Deprecated 
end portal_Link

command portal_GoUrl someURL,pJournalLabel
   set the socketTimeoutinterval to 2000
   #the Browser is called from various contexts
   # we need to know where we came from in order to 
   # handle returning to the context properly.
   if connectivity_PingServer() = "false" then
      # do nothing, inform user
      dialog_CustomMsg "Offline or Low Bandwidth"
      exit portal_GoURL
   else
      
      put the short name of this stack into oStackName
      portal_SetCurrentStack(oStackName)
      portal_GoStack "view_SivaSivaBrowser"
      set the browser_URL of stack "view_SivaSivaBrowser" to someURL
      put someURL into pTrackdata["webUrl"]
      tracking_RecordActivity oStackName, "navigation/webview", pTrackdata
   end if # closing connectivity check
end portal_GoUrl

command portal_LaunchUrl someURL
   # leave Siva Siva app and open the native web app on the device
   launch url someURL    
end portal_LaunchUrl

command portal_GoLandscapeUrl someURL
   set the browser_URL [true] of stack "view_SivaSivaBrowser" to someURL
   portal_GoStack "view_SivaSivaBrowser"
end portal_GoLandscapeUrl



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



command portal_RemoveStack oStackName
   if stackName <> "Siva-Siva-Portal" then
      close stack oStackName
   end if    
end portal_RemoveStack

------------- Layout section -------------------
# BR: this whole set of handlers is really dedicated to the Portal screens "proper"
# and could remain here .. encapsulated all Davids lay code for the portals in this
# on script, there by separating it entirely from all other message path activity.
# in de-bugging then you could simplyl step through all these if the portals were
# being dynamically rebuilt. 
# buit we might need to move out the portal_GetArray and Set array and Get Set data also
# as these can be useful else where and are not needed for layout as such.
------------------------------------------------------


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

command _DEPRECATED_________
   -------------------------------------------------
end _DEPRECATED_________


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
   put the long id of control 2 of cd "portal" of stack portalHomeStackPath into portalView
   -- put the portal_View of stack portalHomeStackPath into portalView
   return portalView
end portal_GetHomeView

function portal_GetHomeStackPath
   -- we will probably move the "portal home" from "sivasivahome" to the projects home stack "Siva-Siva-Portal"
   -- put the filename of stack "sivasivahome" into portalHomeStackPath
   put the filename of stack "Siva-Siva-Portal" into portalHomeStackPath
   return portalHomeStackPath
end portal_GetHomeStackPath
