script "lib_SivaSivaDevelopment"
--> MetaData
-
license: GPLv3
name: lib_SivaSivaDevelopment
type: library
version: 0.2

/*
Place your development handlers here!
Treat this as a sort of scrap book for handlers you like to use as a convenience in development,
but are not intended to be used in production (you can move them to another stack later if they prove needed).

This library will eventually be moved into a separate authoring project.
These handlers that are useful in development but are not to be used in the final deployed mobile app. 
They should be in "tool" projects outside of a production project.
*/


--> Working on
-
on functionKey keyNumber
   if the optionKey is "Down" then breakpoint
   put the top_Card of the topStack into topCard
   switch keyNumber
      case 10
         stack_ToggleShrink
         break
   end switch
   pass functionKey
end functionKey

command stack_ToggleShrink pStackObject
   if pStackObject is empty then
      put the topStack into pStackObject
   end if
   put the scalefactor of pStackObject into oFactor
   if oFactor = 1 then
      stack_Shrink pStackObject, 0.75
   else
      stack_Shrink pStackObject, 1
   end if
end stack_ToggleShrink

command stack_Shrink scriptObject, pScaleFactor
   if pScaleFactor is empty then put 0.7 into pScaleFactor
   
   put the stack_Name of scriptObject into stackName
   lock screen
   put the topleft of stack stackName into oTopLeft
   set the scaleFactor of stack stackName to pScaleFactor
   
   -- bug in screen rects for shrunk stacks
   put pScaleFactor * item 1 of oTopLeft into item 1 of shrunkTopLeft
   put pScaleFactor * item 2 of oTopLeft into item 2 of shrunkTopLeft
   set the topleft of stack stackName to shrunkTopLeft
   unlock screen
   -- put oTopLeft
end stack_Shrink

command jgAndroidLog  --jg: temporary for testing; sent from Home btn in Home stack  --### REMOVE
   if (the platform = "android") and _androidIsLogging() then 
      put mobile_GetLogFile() into logFile
      answer "Clear or view log:" with "Cancel" or "Clear" or "View"
      if it = "view" then
         answer url ("file:" & logFile)
      else if it = "clear" then
         log_Clear
      end if
   end if
end jgAndroidLog

getprop top_Card
   -- using a virtual custom property sets the target and therefore "this"
   put the long id of this card into cardObject
   return cardObject
end top_Card

function _androidIsLogging
   put the hilite of btn "jg android log" of cd "Legacy" of stack "Siva-Siva-App" into isLogging
   return isLogging
end _androidIsLogging

-- on savingStandalone -- pre-processss
-- if not an Android app, turn off android logging
put (the cRevStandaloneSettings["android"] of me = true) into tIsAndroid
set the hilite of btn "jg android log" of cd "Legacy" of me to tIsAndroid
set the vis of fld "logfld" of cd "Legacy" of me to tIsAndroid
end savingStandalone

-- on standaloneSaved pFolder -- post-process
-- increase build number for next time, turn logging back on
-- Will be saved at next manual save, otherwise we don't want it anyway.
put (the cRevStandaloneSettings["android"] of me = true) into tIsAndroid
if tIsAndroid then
   put the cRevStandaloneSettings["android,version code"] of me into tBuildNum
   add 1 to tBuildNum
   set the cRevStandaloneSettings["android,version code"] of me to tBuildNum
   
   set the hilite of btn "jg android log" of cd "Legacy" of me to tIsAndroid
   set the vis of fld "logfld" of cd "Legacy" of me to false
end if
end standaloneSaved




--> Display
-
/*
Based on an open source script by Scott Rossi:
*/

on showCustomMsg pShow,pMsg,pLoc,pWidth,pHeight
  -- pShow = boolean, show or hide msg grp
  -- pLoc = cd loc for display placement; defaults to 1/4 up from bottom center
  -- pMsg = text to display, defaults to "Getting files"; room for only a couple of words
  set the defaultstack to the topstack
  if pShow <> false then -- show it
    if pMsg = "" then
      answer "No prompt passed" -- or we could use a default message here
      exit showCustomMsg
    end if
    if pLoc = "" then
      put the height of this cd into tV -- calcs lower quarter
      put tV - (tV div 4) into tV
      put (item 1 of the loc of this cd),tV into pLoc
    end if
    buildMsgDisplay pLoc,pMsg,pWidth,pHeight
  else -- clear all
    if there is a fld "alphaDisplayFld" then
      repeat until there is no fld "alphaDisplayFld"
        delete fld "alphaDisplayFld"
      end repeat
    end if
    if there is a grc "alphabkgnd" then
      repeat until there is no grc "alphabkgnd"
        delete grc "alphabkgnd"
      end repeat
    end if
  end if
end showCustomMsg

on buildMsgDisplay pLoc,pTxt,pWidth,pHeight -- revised from Scott Rossi's open source
   -- pLoc = loc for display
   -- pTxt = text string to display; must be fairly short
   try
      set the name of the templateGraphic to "alphabkgnd"
      set the backColor of the templateGraphic to black
      set the lineSize of the templateGraphic to 0
      set the style of the templateGraphic to roundrect
      set the opaque of the templateGraphic to true
      set the width of the templateGraphic to pWidth -- 250 
      set the height of the templateGraphic to pHeight -- 50
      set the blendLevel of the templateGraphic to 50
      set the loc of the templateGraphic to pLoc
      create grc
      reset the templateGraphic
      set the name of the templateField to "alphaDisplayFld"
      set the borderWidth of the templateField to 0
      set the opaque of the templateField to false
      set the traversalOn of the templateField to false
      set the locktext of the templateField to true
      set the autohilite of the templateField to false
      set the textFont of the templateField to "verdana"
      set the textSize of the templateField to 24
      set the textheight of the templateField to 36
      set the textColor of the templateField to white
      set the textAlign of the templateField to center
      set the text of the templateField to pTxt
      set the width of the templateField to pWidth -- 250
      set the height of the templateField to pHeight-4 -- 46
      set the loc of the templateField to pLoc
      
      create fld
      reset the templateField
   catch tErr
      put "Result:" && the result && "Error:" && tErr
      --    log tErr
   end try
end buildMsgDisplay

command testMessagePath pMessage -- is this needed?
   answer pMessage with "OK"
end testMessagePath


--> From API
-
command scaleStackIfNeeded
   if the environment is "development" and (item 4 of the effective working screenRect < 800 )  then
      set the scalefactor of this stack to .75
      set the height of this stack to 736
   end if
end scaleStackIfNeeded

command errorDialog pExecutionError
   if not isMobile() then
      --put pExecutionError
      put item 4 of line 1 of pExecutionError into tBrokenStatement
      put item 2 of line 1 of pExecutionError into tLineNumber
      put line (item 1 of line 1 of pExecutionError) of the scriptExecutionErrors  into tErrorDescription 
      # scriptExecutionErrors  seems to be a global prop in the IDE, no longer the cErrorList custom property of a binary stack
      log_Error tErrorDescription & ":" && tBrokenStatement && "on line" && tLineNumber
   end if
end errorDialog


--> SivaSiva | Files
-
/*
These handler list files in the directories.
*/

function portal_ListThumbImages
   -- a thumb image is not guaranteed to be named beginning with "thumb_"
   put portal_ListImages() into portalImages
   filter portalImages with "*/thumb_*"
   return portalImages
end portal_ListThumbImages

function portal_ListImages
   -- lists all images (it is possible that some may not be used is actua app)
   put sivasiva_PortalImageFolder() into portalImageFolder
   put folder_ListFiles (portalImageFolder) into portalImageFiles
   return portalImageFiles
end portal_ListImages
   

--> Hack
-
/*
Original module config way of doing things.
Moving over to better json array structure
*/

function hack_GetModuleFolderFromArray moduleName, pSivaSivaData
   -- no longer stroing in an array
   if pSivasivaData is not an array then put sivasiva_FetchData() into pSivasivaData
   put pSivasivaData ["module"][moduleName] into moduleArray
   put moduleArray ["moduleFolder"] into moduleFolder
end hack_GetModuleFolderFromArray

function hack_FindPortalImage moduleName, pReturnRelative
   -- hack for now due to lack of structure in json
   -- in case we have not created new json array structure
   
   put hack_GetModuleFolderFromArray (moduleName) into sivasivaModuleFolder
   put sivasiva_GetModuleCongifArray (moduleName) into configurationArray
   put configurationArray ["portal-links"] into portalLinkArray
   repeat for each key portalLinkName in portalLinkArray
      put portalLinkArray [portalLinkName]["image"] into relativeImagefile
      set the itemdelimiter to slash
      put item -1 of relativeImagefile into shortFile
      set the itemdelimiter to "_"
      if item 1 of shortFile = "thumb" then next repeat
      
      if pReturnRelative is true then
         return relativeImagefile
      else
         put sivasivaModuleFolder & relativeImagefile into imageFile
      end if
      return imageFile
   end repeat
   return empty
end hack_FindPortalImage

function hack_ListPortalLinks moduleName
   put sivasiva_GetModuleCongifArray (moduleName) into configurationArray
   put configurationArray ["portal-links"] into portalLinkArray
   repeat for each key portalLinkName in portalLinkArray
      put portalLinkArray [portalLinkName]["image"] into relativeImageFile
      
      -- this should not be needed (we use here to check for bugs)
      -- remove in production
      put hack_GetModuleFolderFromArray (moduleName) into moduleFolder
      put moduleFolder & relativeImageFile into imageFile
      if there is not a file imageFile then
         breakpoint
         next repeat -- lets skip liks without images
      end if
      
      set the itemdelimiter to slash
      put item -1 of relativeImageFile into shortFile
      set the itemdelimiter to "_"
      if item 1 of shortFile is not "thumb" then next repeat
      
      put portalLinkName & CR after portalLinks
   end repeat
   delete char -1 of portalLinks
   sort portalLinks
   return portalLinks
end hack_ListPortalLinks

function hack_GetPortalLinkImage portalLinkName, moduleName, pReturnRelative
   put sivasiva_GetModuleCongifArray (moduleName) into configurationArray
   put configurationArray ["portal-links"] into portalLinkArray
   put portalLinkArray [portalLinkName]["image"] into relativeImagefile
   put hack_GetModuleFolderFromArray (moduleName) into sivasivaModuleFolder
   
   if pReturnRelative is true then
      return relativeImagefile
   else
      put sivasivaModuleFolder & relativeImagefile into imageFile
      return imageFile
   end if
end hack_GetPortalLinkImage


--> SivaSiva | Names
-
function sivasiva_ConstructGroupName moduleName
   -- original way of naming groups in home display
   -- hack:  the groups are not consistently named -- "suprise_links" etc
   
   switch moduleName
      case "home"
         return "portal-links"  -- hack
      case "surprise"
         return "surprise_links" 
      default
         put word 1 of moduleName & "-links" into groupName
         return groupName
   end switch
end sivasiva_ConstructGroupName

function sivasiva_RowNameToPortalLink rowName
   set the itemdelimiter to "_"
   delete item 1 of rowName
   return rowName
end sivasiva_RowNameToPortalLink

function sivasiva_PortalLinkToRowName rowName, moduleName
   put word 1 of moduleName & "_" & rowName into rowName
   return rowName
end sivasiva_PortalLinkToRowName
