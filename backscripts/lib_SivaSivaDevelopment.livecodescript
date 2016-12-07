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

/*
-- from old behavior_portal-links.livecode

--> Variables
-
local sMouseLoc, sStartLoc,sBlendLevel,sTargetOwner,sTargetModule,sTargetAction


--> Transitional
-
command portal_PreOpenCard portalName
   sivasiva_InitOrientation "portrait"
   log_Info "sivasiva_InitOrientation"
   
   -- module_LoadConfiguration portalName
   -- put getModuleConfiguration (portalName) into sConfigA
   put sivasiva_GetModuleConfigArray (portalName) into sConfigA
   
   set the acceleratedRendering of this stack to true
   loadPortalImages sConfigA
end portal_PreOpenCard

on preOpenCard
   put _getPortalName() into portalName
   portal_PreOpenCard portalName
   pass preOpenCard
end preOpenCard

private function _getPortalName
   set the itemdelimiter to "-"
   put item 1 of the short name of this card into portalName
   return portalName
end _getPortalName
   
on opencard
   put the short name of me into portalGroupName
   
   set the blendLevel of button "home-Logo" to 0
   send hideLogo to me in 1 second
   set the vScroll of me  to 0 -- ensures correct initial alignment
   send "createScroller portalGroupName" to me in 500 milliseconds -- jg: does nothing if not mobile
end opencard

on closeCard
   put the short name of me into portalGroupName
   deleteMobileControl portalGroupName -- jg: does nothing if not mobile
end closeCard

on relaunch
   --  log_Info "went back to home module"
end relaunch

command loadImage pImg, pTarget
   -- put (getPathToModulesFolder() & "home/" & pImg) into tImgPath
   set the itemdelimiter to slash
   put item -1 of pImg into shortFile
   put sivasiva_PortalImageFile (shortFile) into tImgPath
   
   log_Info "Loading image:" && tImgPath
   set the filename of pTarget to tImgPath
end loadImage

on launchAction pKey
   put sConfigA[pKey]["action"] into tAction
   
   switch
      case "//" is in tAction
         launchURL tAction
         break
      default
         break
   end switch
end launchAction



--> Original
-
command hideLogo
   repeat with x = 1 to 100
      # not good to use "wait" in any mobile context.. 
      # it blocks so the scrolling will fail until the 
      # wait is over.
     send "setBlendLevel x"  to me in 2 milliseconds
   end repeat
end hideLogo

command setBlendLevel pLevel
   if there is a btn "home-logo" then set the blendLevel of btn "home-Logo" to pLevel
end setBlendLevel

on mouseDown
  parseTargetOwner 
  put the mouseloc into sMouseLoc
  put sMouseLoc into sStartLoc
  if not isMobile() then -- jg: mobile will use stack handlers to scroll instead
    setScroll
  end if
end mouseDown

on parseTargetOwner
   put the short name of the owner of the target into sTargetOwner

  # parse the owner
  set the itemdel to "_"
  put item 1 of sTargetOwner into sTargetModule
  put item 2 of sTargetOwner into sTargetAction
  
end parseTargetOwner

on setScroll
  if the mouse is down then
    lock screen
    if item 2 of sMouseLoc > the mouseV then
      set the vscroll of me to the vscroll of me - (the mouseV - item 2 of sMouseLoc)
    else
      set the vscroll of me to the vscroll of me + (item 2 of sMouseLoc - the mouseV)
    end if
    put the mouseloc into sMouseLoc
    send "setScroll" to me in 20 millisec
    unlock screen
  else
    put empty into sMouseLoc
  end if
end setScroll

## jg: using touch msgs on android, because something is blocking mouseUps when scroller is active;
on touchStart pID
  mouseDown
end touchStart

on touchEnd pID
  mouseUp
end touchEnd


on  mouseUp
   
   # by convention the links on these portal pages are groups of three objects
   # label field, image, and a background, these are the mouse targets
   # each of these groups is explicitly named
   # by this convention: modulename[underscore]specific-link-target-action
   # So we are depending on the short name of the immediate owner of the target
   
   if abs(the mouseV - item 2 of sStartLoc) <= 10 then
      
      # user tapped
      
      switch  sTargetModule
         
         case "home"
            --        close this stack --jg: let loadModule handle this to avoid screen flash
            switch sTargetAction
               case "gems"
                  loadModule "gems"
                  break
               case "surprise"
                  loadModule "surprise"
                  break
               case "look"
                  loadModule "look"
                  break
                  
               case "listen"
                  loadModule "listen"
                  break
                  
               case "practice"
                  loadModule "practice"
                  break
                  
               case "read"
                  loadModule "read"
                  break
               case "website"
                  loadModule "website"
                  break
               case "games"
                  loadModule "fun"
                  break
            end switch
            break
            # End of actions for the Home module Links Card
         Case "gems"
            -- put sTargetOwner
            break
            # End of actions for the Gems module  Card
         case "surprise"
            if sTargetAction="video" then
               fetchRandomMediaItem ("media_type","video")
               put getMediaURL ()  into sURL
               launchURL "landscape", sURL
               exit mouseUp
            else
               go to card sTargetOwner
            end if
            break
            # End of actions for the Surprise Module Links 
         Case "listen"
            --put sTargetOwner
            switch sTargetAction
               case "all-bodhinatha"
                  go to card "bodhinatha-talks"
                  break
            end switch
            break
            # End of actions for the Listen Module  Links Card
         Case "look"
            -- put sTargetOwner
            break
            # End of actions for the Look Module  Links Card
         Case "practice"
            switch sTargetAction
               case "workout"
                  loadModule "workout"
                  break
                  case "color-meditation"
                  loadModule "color-meditation"
                  break
            end switch
            break
            # End of actions for the Practice Module  Links Card
         Case "read"
            switch sTargetAction
               case "traits"
                  loadModule "traits"
                  break
            end switch
            break
            # End of actions for the Read Module  Links Card
         Case "website"
            switch sTargetAction
               case "daily-blog"
                  launchURL "portrait", "https://www.himalayanacademy.com/blog/taka/"
                  break
               case "meet-monks"
                  launchURL "portrait", "https://www.himalayanacademy.com/monastery/meet-the-monks"
                  break
               case "monthly-news"
                  launchURL "portrait", "https://www.himalayanacademy.com/monastery/newsletter"
                  break
               case "visit"
                  launchURL "portrait", "https://www.himalayanacademy.com/visit"
                  break
               case "virtual-tour"
                  launchURL "portrait", "https://www.himalayanacademy.com/visit/virtual-tour"
                  break
               case "about-the-monastery"
                  launchURL "portrait", "https://www.himalayanacademy.com/monastery/about"
                  break
               case "our-guru-lineage"
                  launchURL "portrait", "https://www.himalayanacademy.com/monastery/lineage-philosophy/lineage"
                  break
            end switch
            
            break
            # End of actions for the Website Module  Links Card
            
         Case "fun"
            switch sTargetAction
               case "humor"
                  Answer "Load Humor" with "OK"
                  --loadModule "humor"
                  break
               case "word-puzzles"
                  loadModule "wordpuzzles" # landscape stack
                  break
               case "coloring"
                  Answer "Load word-puzzles" with "OK"
                  --loadModule "coloring"
                  break
                  
               case "image-puzzles"
                  Answer "Load image-puzzles" with "OK"
                  --loadModule "image-puzzles"
                  break
            end switch
            # End of actions for the Fund Module  Portal-links group
            
            break
            
      end switch
      
   end if
   
end  mouseup
*/
