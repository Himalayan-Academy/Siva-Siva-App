Script "stack_listen_card_id_1158"

/*
# Name: card "listen-collection" of stack "listen"
# ID: card id 1158 of stack "listen"
*/


local sStartX, sStartY,sStartLoc,sStartHScroll, sStartYScroll
local tHGroup, sLoadingIndicator
## touch commands to scroll the groups

--on preopencard
--   put the long id of control "loading" into sLoadingIndicator
--   setCardCoords
--   pass preopencard
--end preopencard


on opencard
   audioIsRunning
end opencard


on touchStart pTouchID
   if the short name target is "Loading"then
      showBusyIndicator false
      if isMobile() then
         mobileClearTouches
      end if
      exit top 
   else
      put empty into sStartX
      put empty into sStartY
      
      put the vScroll of grp "all-collections" into sStartYScroll
      
      put the long owner of the target into tHGroup  
      put the hScroll of tHGroup into sStartHScroll
   end if
end touchStart


on touchMove pTouchID, pTouchX, pTouchY
   if sStartY is empty then 
      put pTouchY into sStartY
   end if
   
   if sStartX is empty then
      put pTouchX into sStartX
   end if
   
   // Check for vertical scroll
   
   if pTouchY > (sStartY + 60) or pTouchY < (sStartY -60) then
      set the vScroll of group "all-collections" to sStartYScroll + (sStartY-pTouchY)
   else
      
      if pTouchX > (sStartX + 3) or pTouchX < (sStartX - 3) then
         // Check for horizontal scroll
         
         put the long owner of the target into tHGroup  
         set the hScroll of tHGroup to sStartHScroll + (sStartX-pTouchX)
         
      end if
   end if
   
end touchMove


on touchEnd pTouchID
   -- code
end touchEnd


on touchRelease pTouchID
   -- code
end touchRelease


## responds to user to interaction

on mouseDown 
   put the mouseloc into sStartLoc
   put the long owner of the target into tHGroup 
   if not isMobile() then -- jg: mobile will use stack handlers to scroll instead    
      setScroll tHGroup  
   end if
end mouseDown


on mouseup
   local pSelection
   if the short name target is "Loading"then
      showBusyIndicator false
      if isMobile() then
         mobileClearTouches
      end if
      exit top 
   end if
   
      if abs(the mouseH - item 1 of sStartLoc) <= 1 and abs(the mouseV - item 2 of sStartLoc) <= 1 then
         put the target into pSelection
         selectPlayList pSelection # handles collection and other clicks on the UI
      end if
   end mouseup


----------------------------------------------
## Desktop scrolling

on setScroll tHGroup
   if the mouse is down then
      lock screen
      
      if abs (item 2 of sStartLoc ) > 50 then
         if item 2 of sStartLoc > the mouseV then
            set the vscroll of grp "all-collections" to the vscroll of grp "all-collections" - (the mouseV - item 2 of sStartLoc)
         else
            set the vscroll of grp "all-collections" to the vscroll of grp "all-collections" + (item 2 of sStartLoc - the mouseV)
         end if  
      end if  
      if abs (item 1 of sStartLoc ) > 40 then
         if item 1 of sStartLoc > the mouseH then
            set the hscroll of tHGroup to the hscroll of tHGroup - (the mouseH - item 1 of sStartLoc)
         else
            set the hscroll of tHGroup to the hscroll of tHGroup+ (item 1 of sStartLoc - the mouseH)
         end if
      end if
      put the mouseloc into sStartLoc
      send "setScroll tHGroup" to me in 20 millisec
      unlock screen
   else
      put empty into sStartLoc
   end if
   
end setScroll

