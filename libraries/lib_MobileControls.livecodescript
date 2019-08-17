script "lib_MobileControls"
--> MetaData
-
license: GPLv3
name: lib_MobileControls
type: library
version: 0.2

/*
This stack has been moved from a frontscript to a library.

The suggestion is to split this into general and more specific libraires - for instance lib_MobileScroller and lib_MobileAudio etc ?
*/

######### Mobile Player Controls ############
# libMobileAudioPlayer v1.0 beta
# Brahmanathaswami - copied from Gurudeva.app, code by Jacqueline Landman Gay
# Himalayan Academy 2016

---------------------------------------------------------------------------------------
global gPlayerIsRunning
# needed to allow audio to run freely as user moves to other cards

local sPlayerId, sPlayerRect

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
--         08/15/2019: BWM - add sPlayerRect, getMobileAudioPlayerRect for responsive use
---------------------------------------------------------------------------------------

command createMobileAudioPlayer pURL, pPlayerName, pRect
   local tHeight
   if pPlayerName is among the lines of mobileControls() then
      mobileControlDelete pPlayerName -- init
   end if
   mobileControlCreate "player", pPlayerName
   put the result into sPlayerId
   
   if pRect is empty then
      put the rect of player pPlayerName into pRect 
   end if
   
   -- adjust location for mobile:--### FIND OUT IF THIS IS NEEDED ON iOS
   if the platform is "android" then
      if the short name of this card is "surprise_audio" then
         subtract 70 from item 2 of pRect
      else
         -- android player controls appear above the player; adjust
         -- with controller it's about 4x rect of cd player so align the bottom edges:
         # this is hard wired to the bottom of the card for now.
         put item 4 of pRect - item 2 of pRect into tHeight
         put CardHeight() - safeBottomMargin() - 70 into item 4 of pRect
         put (item 4 of pRect) - tHeight - 50 into item 2 of pRect
      end if
   end if
   put pRect into sPlayerRect
   mobileControlSet pPlayerName, "visible", true 
   mobileControlSet pPlayerName, "rect", pRect
   mobileControlSet pPlayerName, "showController", true 
   mobileControlSet pPlayerName, "filename", pURL 
   if pURL begins with "https" then
      showBusyIndicator true, "Loading audio..." -- add loading indicator until duration is available
   end if
   if mobileIdleTimerLocked() is false then
      mobileLockIdleTimer --jg: disallow screen lock
   end if
end createMobileAudioPlayer 

function getMobileAudioPlayerRect
   return sPlayerRect
end getMobileAudioPlayerRect

on playerPropertyAvailable theProperty -- msg sent when enough has content is loaded
   if theProperty is "duration" then
      showBusyIndicator false -- Remove the "Loading..." indicator and start playing
      mobileControlDo sPlayerId, "play"
   end if
end playerPropertyAvailable


command setMobileAudioPlayer pPlayerName, pState, pTimeStamp
   --jg: control the state of the mobile player
   -- pState = "pause", "play", or "stop"
   mobileControlDo pPlayerName, pState
   if pState = "stop" then
      showBusyIndicator false -- in case it's still showing
      mobileControlSet pPlayerName, "visible", false
      mobileControlDelete pPlayerName
      put empty into sPlayerRect
      if mobileIdleTimerLocked() is true then 
         mobileUnlockIdleTimer
      end if
      get runningAudioIndicatorVis("false")
      # above is need to ensure we hide the icon that show audio is playing stop button/icon
      # we set a local in the backscript lib_SivaSiva that we query when going 
      # to any context where this icon should appear
   else
      mobileControlSet pPlayerName, "currentTime", pTimeStamp
      get runningAudioIndicatorVis("true")
   end if
end setMobileAudioPlayer


on playerFinished -- sent on mobile when audio is done
   if mobileIdleTimerLocked() is true then mobileUnlockIdleTimer
   mobileControlDelete sPlayerId
   put empty into sPlayerRect
   get runningAudioIndicatorVis("false")
end playerFinished


command showPlayer pBool, pPlayerName --jg: handles visibility of both mobile and desktop players
   -- if audio is playing, player is shown on audio card, hidden elsewhere;
   -- pBool = boolean
   if isMobile() then
      hide player pPlayerName -- the LC one; never show it
      mobileControlSet pPlayerName, "showController", pBool
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
   local tList
   if not isMobile() then exit deleteAllMobileControls
   put mobileControls() into tList
   if not (tList contains "audioPlayer") then # play we terminated
      get runningAudioIndicatorVis("false")
   end if
   repeat for each line l in tList
      # we are keeping the player running as per user requests.
      # you need to use an explicit stop/remove in the UI/UX context
      if l contains "audioPlayer" then
         next repeat
      end if  
      mobileControlDelete l
   end repeat
end deleteAllMobileControls

command showBusyIndicator pBool, pMsg --jg: for both desktop and mobile
   if isMobile() then
      if pBool = true then
         mobileBusyIndicatorStart "square", pMsg -- add loading indicator until duration is available
      else
         mobileBusyIndicatorStop
      end if
   else
      if there is a btn "loading" then
         set the vis of btn "loading" to pBool
      end if
   end if
end showBusyIndicator


