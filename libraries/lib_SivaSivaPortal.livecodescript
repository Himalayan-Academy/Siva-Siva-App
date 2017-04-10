script "lib_SivaSivaPortal"
--> MetaData
-
license: GPLv3
name: lib_SivaSivaPortal
type: library
version: 0.2
Original Script by David Bovill

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
local LocalArray, sCurrentPortal,sLastStack


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

command portal_GoUrl someURL
   #the Browser is called from various contexts
   # we need to know where we came from in order to 
   # handle returning to the context properly.
   put the short name of this stack into oStackName
   portal_SetCurrentStack(oStackName)
   set the browser_URL of stack "view_SivaSivaBrowser" to someURL
   portal_GoStack "view_SivaSivaBrowser"
end portal_GoUrl

command portal_LaunchUrl someURL
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
      portal_GoStack "Siva-Siva-App" -- does nothing if in the portal stack
   end if
   put portal_GetHomeView() into portalView
   
   portal_SetCurrent portalName
   portal_SetCurrentStack "Siva-Siva-App"
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

command portal_GoStack cardOrStackObject --  stackName
   -- goes to the new stack
   -- closes the current stack  unless we are launching from portal
   -- or opening a browser window...
   -- safely ignores if we are already in the new stack
   
   # BR: we need to know where we are to make the right decision
   # on whether to close the stack or note
   put the short name of this stack into oStackName
   portal_SetCurrentStack oStackName
   
   if not  (oStackName= "Siva-Siva-App"  OR stackName= "view_SivaSivaBrowser")  then
      # only other stacks   For now we are testing to close the main stack too 
      # to try and solve the problem on Android...
      close stack oStackName  # be sure all stacks are set to destroy on close
   end if
   
   go  cardOrStackObject in a new window -- to stack stackName
   put the short name of this stack into sLastStack
   
end portal_GoStack

command portal_RemoveStack oStackName
    if stackName <> "Siva-Siva-App" then
        close stack oStackName
    end if    
end portal_RemoveStack 


# BR:  Portal_Go is deprecated
# we have combined going to a stack opr to a card in a stack into one handler:
# portal_GoStack  because there is where the problems are on Android.
# We are leaving the mainstack open and then opening new stacks on top of that stack
# this is working perfectly on Desktop and iOS, but not on Android.


-- command portal_Go cardOrStackObject
--    -- answer portal_Go
--    /*
--    This handler is for navigating to other card in stacks outside of the portal group in the sivasivahome stack.
--    Because we have set the stackfiles we can simply go to the short name of the stack.
--    The exception to this is the Siva-Siva-App" project home stack, which if it is closed menas that we loose the stackfiles capability!
--    */

--    put the short name of this stack into oStackName
--    go cardOrStackObject in a new window
--    put the result into goResult
--    put the stack_Name of cardOrStackObject into newStackName
--    if newStackName is oStackName then
--       if the long id of cardOrStackObject = the long id of this card then
--          -- the button or icon should proably be changed or disabled
--       else
--          -- going to a different card in the same stack
--          -- answer "Not closing. Destination is the same stack."
--       end if
--    else
--       if the environment is "Mobile" then
--           close stack oStackName
--       end if
--    end if
--    return goResult
-- end portal_Go


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
   -- we will probably move the "portal home" from "sivasivahome" to the projects home stack "Siva-Siva-App"
   -- put the filename of stack "sivasivahome" into portalHomeStackPath
   put the filename of stack "Siva-Siva-App" into portalHomeStackPath
   return portalHomeStackPath
end portal_GetHomeStackPath
