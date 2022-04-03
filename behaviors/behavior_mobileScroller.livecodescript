script "behavior_mobileScroller"
local sMouseLoc, sStartLoc
local sStacksHorizontal
local sName, sImageScroller

######### Mobile Controls ############

command createScroller pName -- scrolling fields
   local tRect
   put false into sImageScroller
   if not isMobile() then
      put pName into sName
      exit CreateScroller
   end if
   deleteMobileControl pName -- delete any existing
   put (the rect of control pName) into tRect
   mobileControlCreate "scroller", pName
   mobileControlSet pName, "rect", tRect
   put ("0,0," & (the formattedwidth of control pName) & "," & \
         the formattedheight of control pName + 60) into tRect
   mobileControlSet pName, "contentRect", tRect
   wait 10 milliseconds -- Panos workaround, bug #18924
   mobileControlSet pName, "hScroll", 0
   mobileControlSet pName, "vScroll", 0
   mobileControlSet pName, "hIndicator", false
   if pName = "quote" then
      mobileControlSet pName, "vIndicator", true
   end if
   mobileControlSet pName, "visible",  true
end createScroller

command createImageScroller pName
   local tRect
   put true into sImageScroller
   if not isMobile() then
      put pName into sName
      exit createImageScroller
   end if
   deleteMobileControl pName -- delete any existing
   put (the rect of control pName) into tRect
   mobileControlCreate "scroller", pName
   mobileControlSet pName, "rect", tRect
   put ("0,0," & (the formattedwidth of control pName) & "," & \
         the formattedheight of control pName) into tRect
   mobileControlSet pName, "contentRect", tRect
   wait 10 milliseconds -- Panos workaround, bug #18924
   mobileControlSet pName, "hScroll", the hScroll of control pName
   mobileControlSet pName, "vScroll", the vScroll of control pName
   mobileControlSet pName, "hIndicator", false
   mobileControlSet pName, "vIndicator", false
   mobileControlSet pName, "visible",  true
end createImageScroller

on updateScroller pName
   -- NOTE: this is not intended for image scrollers
   local tRect
   if not isMobile() then exit updateScroller
   if pName is among the lines of mobileControls() then -- update
      put ("0,0," & (the formattedwidth of control pName) & "," & \
            the formattedheight of control pName + 60) into tRect
      mobileControlSet pName, "contentRect", tRect
      mobileControlSet pName, "hScroll", 0
      mobileControlSet pName, "vScroll", 0 --the vScroll of control pName
   else
      createScroller pName
   end if
end updateScroller


on scrollerDidScroll hScrolled, vScrolled
   local tControlID
   put mobileControlTarget() into tControlID
   if sImageScroller then
      set the vscroll of control tControlID to vScrolled
      set the hscroll of control tControlID to hScrolled
      exit scrollerDidScroll
   else if vScrolled < 20 then
      set the vscroll of control tControlID to vScrolled * 2
   else
      set the vscroll of control tControlID to vScrolled + 20
   end if
   if short name of this stack is among the items of sStacksHorizontal then
      set the hscroll of control tControlID to hScrolled
   end if
end scrollerDidScroll


on deleteMobileControl pName -- jg: deletes an existing mobile control
   -- native controls should be deleted if possible when no longer needed, as
   -- they are overlaid on the stack and will float over all cards
   if not isMobile() then
      if pName is sName then put empty into sName
      exit deleteMobileControl -- do nothing on desktop
   end if
   repeat while pName is among the lines of mobileControls()
      mobileControlDelete pName
   end repeat
   put "" into sMouseLoc
   put "" into sStartLoc
   --set the acceleratedRendering of this stack to false --- jg: don't turn this off
end deleteMobileControl


on mouseDown
   put the mouseloc into sMouseLoc
   put sMouseLoc into sStartLoc
   if not isMobile() and sName is not empty then -- jg: mobile will use stack handlers to scroll instead
      setScroll
   end if
   pass mousedown
end mouseDown


on mouseUp
   put "" into sMouseLoc
   if sImageScroller then
      if abs(the mouseH - item 1 of sStartLoc) <= 10 and abs(the mouseV - item 2 of sStartLoc) <= 10 then
         send "doScrollerTap" to the target
      end if
   else
      pass mouseUp
   end if
end mouseUp


on mouseRelease
   put "" into sMouseLoc
   put "" into sStartLoc
end mouseRelease

on mouseMove x,y -- desktop scrolling
   if isMobile() or sMouseLoc = "" then pass mouseMove
   setScroll
end mouseMove

--on mouseMove x,y -- desktop scrolling
--   local tHDist,  tVDist
--   if isMobile() or sMouseLoc = "" then pass mouseMove
--   put abs(x - item 1 of sMouseLoc) into tHDist
--   put abs(y - item 2 of sMouseLoc) into tVDist
--   --  lock screen
--   if item 2 of sMouseLoc > y then -- pushing up
--      if not (the name of me contains "field") then set the hscroll of me to the hscroll of me + tHDist -- bgImg okay
--      set the vscroll of me to the vscroll of me + tVDist
--   else if item 2 of sMouseLoc < y then -- pushing down
--      if not (the name of me contains "field") then set the hscroll of me to the hscroll of me - tHDist
--      set the vscroll of me to the vscroll of me - tVDist
--   end if
--   put x,y into sMouseLoc
--   --  unlock screen
--end mouseMove

on setScroll
   local tMouseH, tMouseV
   if the mouse is down then
      lock screen
      put the mouseH into tMouseH
      put the mouseV into tMouseV
      if abs (item 2 of sMouseLoc ) > 20 then
         if item 1 of sMouseLoc > tMouseH then
            set the hscroll of me to the hscroll of me - (tMouseH - item 1 of sMouseLoc)
         else
            set the hscroll of me to the hscroll of me + (item 1 of sMouseLoc - tMouseH)
         end if
         if item 2 of sMouseLoc > tMouseV then
            set the vscroll of me to the vscroll of me - (tMouseV - item 2 of sMouseLoc)
         else
            set the vscroll of me to the vscroll of me + (item 2 of sMouseLoc - tMouseV)
         end if
         put the mouseloc into sMouseLoc
      end if
      send "setScroll" to me in 20 millisec
      unlock screen
   else
      put empty into sMouseLoc
   end if
end setScroll
