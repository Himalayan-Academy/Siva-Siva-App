script "mobileScroller"


######### Mobile Controls ############


---------------------------------------------------------------------------------------
General commands: Deletion for any type of mobile control
---------------------------------------------------------------------------------------

command deleteMobileControl pName -- jg: deletes an existing mobile control
  -- native controls should be deleted if possible when no longer needed, as
  -- they are overlaid on the stack and will float over all cards
  -- pName can be a name string or a numerical ID
  if not isMobile() then exit deleteMobileControl -- do nothing on desktop
  repeat while pName is among the lines of mobileControls()
    mobileControlDelete pName
  end repeat
end deleteMobileControl

command deleteAllMobileControls -- jg: delete all mobile controls of any type, in all stacks
  if not isMobile() then exit deleteAllMobileControls
  put mobileControls() into tList
  repeat for each line l in tList
    mobileControlDelete l
  end repeat
end deleteAllMobileControls


---------------------------------------------------------------------------------------
Mobile scroller controls
---------------------------------------------------------------------------------------

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
  --  ANSWER TCONTROLNAME  --###
  --  set the vscroll of tControlID to pVScrolled
  set the vscroll of TCONTROLNAME to pVScrolled --###
  pass scrollerDidScroll
end scrollerDidScroll




---------------------------------------------------------------------------------------
Mobile audio player controls
---------------------------------------------------------------------------------------

# libMobileAudioPlayer v1.0 beta
# Brahmanathaswami - copied from Gurudeva.app, code by Jacqueline Landman Gay
# Himalayan Academy 2016

-- createMobileAudioPlayer
-- DESCRIPTION
--        
-- PARAMETERS
--		pURL: the path to the audio file, either http or local
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

global gPlayerIsRunning
# needed to allow audio to run freely as user moves to other cards

local sPlayerID

command createMobileAudioPlayer pURL, pPlayerName
  if sPlayerID is in mobileControls() then mobileControlDelete sPlayerID -- init
  mobileControlCreate pPlayerName
  put the result into sPlayerId
  -- adjust location for mobile:
  put the rect of player pPlayerName into tRect
  --  put (the bottom of img 1) - 10 into item 4 of tRect --### FIND OUT IF THIS IS NEEDED
  --  put item 4 of tRect -  50 into item 2 of tRect
  mobileControlSet sPlayerId, "rect", tRect
  mobileControlSet sPlayerId, "showController", true 
  mobileControlSet sPlayerId, "filename", pURL 
  mobileControlSet sPlayerId, "visible", true 
  if pURL begins with "http" then
    mobileBusyIndicatorStart "square", "Loading audio..." -- add loading indicator until duration is available
  end if
  if mobileIdleTimerLocked() is false then mobileLockIdleTimer --jg: disallow screen lock
end createMobileAudioPlayer 

on playerPropertyAvailable theProperty -- msg sent when enough has content is loaded
  if theProperty is "duration" then
    mobileBusyIndicatorStop -- Remove the "Loading..." indicator and start playing
    if the platform = "android" then
      --      show grc "Show Controller" of cd "audio" --### WHICH CD?
    end if
    mobileControlDo sPlayerId, "play"
  end if
end playerPropertyAvailable

command setMobileAudioPlayer pState --jg: control the state of the mobile player
  -- pState = "pause", "play", or "stop"
  mobileControlDo sPlayerId, pState
  if pState = "stop" then
    mobileBusyIndicatorStop -- in case it's still showing
    mobileControlSet sPlayerId, "visible", false
    mobileControlDelete sPlayerId
    if mobileIdleTimerLocked() is true then mobileUnlockIdleTimer
    --    hide grc "Show Controller" of cd "audio" --### WHICH CD?
  end if
end setMobileAudioPlayer

on playerFinished -- sent on mobile when audio is done; reset icon
  if there is a grp "soundIsPlaying" then hide grp "soundIsPlaying"
  --  hide grc "Show Controller" of cd "audio" --### WHICH CD?
  if mobileIdleTimerLocked() is true then mobileUnlockIdleTimer
end playerFinished

--on playStopped -- sent on desktop when audio is done
--   if there is a grp "soundIsPlaying" then hide grp "soundIsPlaying"
--end playStopped

command showPlayer pBool, pPlayerName --jg: handles visibility of both mobile and desktop players
  -- if audio is playing, player is shown on audio card, hidden elsewhere;
  -- pBool = boolean
  if isMobile() then
    mobileControlSet sPlayerId, "showController",pBool
    mobileControlSet sPlayerId, "visible", pBool
  else
    set the vis of player pPlayerName to pBool
  end if
end showPlayer


