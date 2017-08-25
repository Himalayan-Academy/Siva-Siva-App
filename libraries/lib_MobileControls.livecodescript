script "lib_MobileControls"
--> MetaData
-
license: GPLv3
name: lib_MobileControls
type: library
version: 0.2

/*
This stack has been moved from a frontscript to a library.

The suggestion is to split this into general and more specific libraires - for instance lib_MobileScroller and lib_MobileAdio etc ?
*/

--> Variables
-
/*
Here we store information about the target of the scrolling action such as:

-  LocalArray ["scrollingview"] = the long id of the target of the field or group to scroll.
*/

local LocalArray


--> Working On
-
private command displayScroll vScrolled
   -- in case you want to debug directly on the portal screen
   -- should remove when deployed as only useful for debiggin portal screens
   
   put the scrolling_View of cd 1 of stack "sivasivahome" into scrollingView
   put the row_View [1] of scrollingView into rowView
   set the title_Text of rowView to vScrolled
end displayScroll


--> Mobile | Scroller | Geometry
-
getprop formatted_VerticalRect
   put the long id of the target into scrollerObject
   put the rect of scrollerObject into fRect
   put the formattedheight of scrollerObject into item 4 of fRect
   return fRect
end formatted_VerticalRect

getprop formatted_Rect
   put the long id of the target into scrollerObject
   put the topleft of scrollerObject into sTopLeft
   put the formattedwidth of scrollerObject into fWidth
   put the formattedheight of scrollerObject into fHeight
   put sTopLeft,fWidth,fHeight into fRect
   return fRect
end formatted_Rect

command scroller_SetFormattedRect pIdOrName
   -- a utility function to automatically reset a scroller to the formattedwith and formattedheight
   put LocalArray ["scrollerView"] into scrollingView
   if exists (scrollingView) is false then
      answer scrollingView
      return empty
   end if
   if pIdOrName is empty then
      put LocalArray ["mobileScrollerName"] into pIdOrName
   end if
   
   put the rect of scrollingView into scrollingViewRect
   put the formatted_VerticalRect of scrollingView into fRect
    
   scroller_SetRect pIdOrName, scrollingViewRect, fRect
end scroller_SetFormattedRect

command scroller_SetRect idOrName, groupRect, pFormattedRect
   if the environment is not "mobile" then return false
   
   if pFormattedRect is empty then put groupRect into pFormattedRect
   mobileControlSet idOrName, "rect", groupRect
   mobileControlSet idOrName, "contentRect" , pFormattedRect
   mobileControlSet idOrName, "hScroll" , 0
   mobileControlSet idOrName, "vScroll" , 0
   return true
end scroller_SetRect


--> Mobile | Scroller | Events
--David's method
on scrollerDidScroll hScrolled, vScrolled
   -- this message is sent to the same object that created the mobile scroller (this library)
   -- would prefer to move it to a behavior that an be used in multiple places
   
   -- put mobileControlTarget() into idOrName
   -- if idOrName = "portal scroller" then
   -- put the scrolling_View of cd 1 of stack "sivasivahome" into scrollingView
   -- displayScroll (idOrName &CR& vScrolled)
   
   put LocalArray ["scrollerView"] into scrollingView
   if exists (scrollingView) is false then
      answer scrollingView
      return empty
   end if
   
   set the vscroll of scrollingView to vScrolled
   pass scrollerDidScroll
end scrollerDidScroll

--> Mobile | Scroller
--
setprop mobile_VerticalScroller [fRect] mobileScrollerName
   -- we could also store some information about the scroller as a group property ?
   -- for now let's just use the mobileScrollerName
   put the long id of the target into scrollerView
   put scrollerView into LocalArray ["scrollerView"]
   
   switch
      case the environment is not "mobile"
         return false
      case mobileScrollerName is empty
         scroller_Delete mobileScrollerName
         return the result
      case mobileScrollerName is not among the lines of mobileControls()
         scroller_Create mobileScrollerName
         put the result into mobileScrollerID
         break 
      default
         answer ("Error" && existingControls)
   end switch
   
   set the vScroll of scrollerView to 0 -- ensures correct initial alignment
   put the rect of scrollerView into scrollingViewRect
   if fRect is empty then put the formatted_VerticalRect of scrollerView into fRect
   
   scroller_SetRect mobileScrollerID, scrollingViewRect, fRect
   scroller_ShowVertical mobileScrollerID
   
   -- answer scrollingViewRect & CR & fRect & CR & mobileScrollerID & CR & "mobile_VerticalScroller"
   
   put mobileScrollerName into LocalArray ["mobileScrollerName"]
   return mobileScrollerID
end mobile_VerticalScroller

getprop mobile_VerticalScroller
   -- not needed ?
   if the environment is not "mobile" then return false
   put mobileControlTarget() into idOrName
   return idOrName
end mobile_VerticalScroller

command scroller_Delete mobileScrollerName
   if the environment is not "mobile" then return false
   mobileControlDelete mobileScrollerName
   return mobileControls()
end scroller_Delete

command scroller_Create mobileScrollerName
   -- create if mobile scroller does not exist already (returns a unique id)
   if the environment is not "mobile" then return false
   
   put mobileControls() into mobileControllerNames
   if mobileScrollerName is among the lines of mobileControllerNames then
      put mobileControlGet (mobileScrollerName, "id") into mobileScrollerID
   else
      mobileControlCreate "scroller", mobileScrollerName
      put the result into mobileScrollerID
   end if
   return mobileScrollerID
end scroller_Create

command scroller_ShowVertical idOrName
   if the environment is not "mobile" then return false
   
   mobileControlSet idOrName, "hIndicator" , false
   mobileControlSet idOrName, "vIndicator", true
   mobileControlSet idOrName, "visible",  true
end scroller_ShowVertical




######### Mobile Player Controls ############
# libMobileAudioPlayer v1.0 beta
# Brahmanathaswami - copied from Gurudeva.app, code by Jacqueline Landman Gay
# Himalayan Academy 2016

---------------------------------------------------------------------------------------
global gPlayerIsRunning
# needed to allow audio to run freely as user moves to other cards

local sPlayerId 
local pPlayerName -- jg: may not need this any more; check

---------------------------------------------------------------------------------------
-- createMobileAudioPlayer
-- DESCRIPTION
--        
-- PARAMETERS
--		pURL: the ath to the audio file, either http or local
--		pPlayerName: this could be called from any module and the player name will vary
-- Usage: Call this handler to instantiate the player and make it visible
-- If intent is to show when card opens, then call from preopencard handler.
-- if intent is to show dynamically (i.e. default is hidden until the User what to listen to something) then call from the button/or handler using:
-- if intent it is to let audio run while user does other things in the app then
-- set global: something like this  show grp "soundIsPlaying"
--      put 1 into gPlayerIsRunning # use this later when stopping the sound...
-- CHANGES
--         07/20/2016: Brahmanathaswami - updated
---------------------------------------------------------------------------------------


command createMobileAudioPlayer pURL, pPlayerName,tRect
   if pPlayerName is among the lines of mobileControls() then mobileControlDelete pPlayerName -- init
   mobileControlCreate "player",pPlayerName
   put the result into sPlayerId
   -- adjust location for mobile:--### FIND OUT IF THIS IS NEEDED ON iOS
   if tRect is empty then
      put the rect of player pPlayerName into tRect 
   end if   
   if the platform is "android" then -- android player controls appear above the player; adjust
      -- with controller it's about 4x rect of cd player so align the botom edges:
      # this his hard wired to the bottom of the card for now.
      put (the height of this card)  -70  into item 4 of tRect
      put item 4 of tRect - item 2 of tRect into tHeight
      subtract tHeight from item 2 of tRect
   end if
   mobileControlSet pPlayerName, "visible", true 
   mobileControlSet pPlayerName, "rect", tRect
   mobileControlSet pPlayerName, "showController", true 
   mobileControlSet pPlayerName, "filename", pURL 
   if pURL begins with "https" then
      showBusyIndicator true, "Loading audio..." -- add loading indicator until duration is available
   end if
   if mobileIdleTimerLocked() is false then mobileLockIdleTimer --jg: disallow screen lock
end createMobileAudioPlayer 

on playerPropertyAvailable theProperty -- msg sent when enough has content is loaded
   if theProperty is "duration" then
      showBusyIndicator false -- Remove the "Loading..." indicator and start playing
      mobileControlDo pPlayerName, "play"
   end if
end playerPropertyAvailable

command setMobileAudioPlayer pPlayerName, pState,pTimeStamp --jg: control the state of the mobile player
   -- pState = "pause", "play", or "stop"
   mobileControlDo pPlayerName, pState
   if pState = "stop" then
      showBusyIndicator false -- in case it's still showing
      mobileControlSet pPlayerName, "visible", false
      mobileControlDelete pPlayerName
      if mobileIdleTimerLocked() is true then 
         mobileUnlockIdleTimer
      end if
   else 
      mobileControlSet pPlayerName, "currentTime", pTimeStamp
   end if
end setMobileAudioPlayer

on playerFinished -- sent on mobile when audio is done
   if mobileIdleTimerLocked() is true then mobileUnlockIdleTimer
   mobileControlDelete pPlayerName
end playerFinished

--on playStopped -- sent on desktop when audio is done
--  if there is a grp "soundIsPlaying" then hide grp "soundIsPlaying"
--end playStopped

command showPlayer pBool, pPlayerName --jg: handles visibility of both mobile and desktop players
   -- if audio is playing, player is shown on audio card, hidden elsewhere;
   -- pBool = boolean
   if isMobile() then
      hide player pPlayerName -- the LC one; never show it
      mobileControlSet pPlayerName, "showController",pBool
      mobileControlSet pPlayerName, "visible", pBool
   else
      set the vis of player pPlayerName to pBool
   end if
end showPlayer

######### Mobile Utilities ############

on deleteMobileControl pName -- jg: deletes an existing mobile control
   -- native controls should be deleted if possible when no longer needed, as
   -- they are overlaid on the stack and will float over all cards
   if not isMobile() then exit deleteMobileControl
   repeat while pName is among the lines of mobileControls()
      mobileControlDelete pName
   end repeat
end deleteMobileControl

on deleteAllMobileControls -- jg: delete all mobile controls of any type in all stacks
   if not isMobile() then exit deleteAllMobileControls
   put mobileControls() into tList
   repeat for each line l in tList
      if l contains "audioPlayer" then
      next repeat
   end if  
   mobileControlDelete l
end repeat
end deleteAllMobileControls

command showBusyIndicator pBool,pMsg --jg: for both desktop and mobile
   if isMobile() then
      if pBool = true then
         mobileBusyIndicatorStart "square", pMsg -- add loading indicator until duration is available
      else
         mobileBusyIndicatorStop
      end if
   else
      if there is a btn "loading"  then
         set the vis of btn "loading"  to pBool
      end if
   end if
end showBusyIndicator
