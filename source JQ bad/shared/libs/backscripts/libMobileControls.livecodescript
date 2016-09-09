script "libMobileControls"

######### Mobile Scroller Controls ############

command CreateScroller pName -- scrolling fields
  if not isMobile() then exit CreateScroller
  deleteMobileControl pName -- delete any existing
  put (the rect of control pName) into tRect
  mobileControlCreate "scroller", pName
  mobileControlSet pName, "rect", tRect
  put  ("0,0," & (the formattedwidth of control pName) & "," & the formattedheight of control pName) into tRect
  mobileControlSet pName, "contentRect" , tRect
  mobileControlSet pName, "hScroll" , 0
  mobileControlSet pName, "vScroll" , 0
  mobileControlSet pName, "hIndicator" , false
  mobileControlSet pName, "vIndicator", true
  mobileControlSet pName, "visible",  true
end CreateScroller

on scrollerDidScroll pHScrolled, pVScrolled
  put mobileControlTarget() into tControlID
  put the long name of control tControlID of this cd of the topstack into tControlName
  set the vscroll of tControlName to pVScrolled
  pass scrollerDidScroll
end scrollerDidScroll

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
    mobileControlDelete l
  end repeat
end deleteAllMobileControls


######### Mobile Player Controls ############
# libMobileAudioPlayer v1.0 beta
# Brahmanathaswami - copied from Gurudeva.app, code by Jacqueline Landman Gay
# Himalayan Academy 2016

---------------------------------------------------------------------------------------
global gPlayerIsRunning
# needed to allow audio to run freely as user moves to other cards

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


command createMobileAudioPlayer pURL, pPlayerName
  if pPlayerName is among the lines of mobileControls() then mobileControlDelete pPlayerName -- init
  mobileControlCreate "player",pPlayerName
  put the result into sPlayerId
  -- adjust location for mobile:--### FIND OUT IF THIS IS NEEDED ON iOS
  put the rect of player pPlayerName into tRect 
  if the platform is "android" then -- android player controls appear above the player; adjust
    -- with controller it's about 4x rect of cd player so align the botom edges:
    put item 4 of tRect - item 2 of tRect into tHeight
    subtract tHeight from item 2 of tRect
  end if
  mobileControlSet pPlayerName, "visible", true 
  mobileControlSet pPlayerName, "rect", tRect
  mobileControlSet pPlayerName, "showController", true 
  mobileControlSet pPlayerName, "filename", pURL 
  if pURL begins with "http" then
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

command setMobileAudioPlayer pState --jg: control the state of the mobile player
  -- pState = "pause", "play", or "stop"
  mobileControlDo pPlayerName, pState
  if pState = "stop" then
    showBusyIndicator false -- in case it's still showing
    mobileControlSet pPlayerName, "visible", false
    mobileControlDelete pPlayerName
    if mobileIdleTimerLocked() is true then mobileUnlockIdleTimer
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

