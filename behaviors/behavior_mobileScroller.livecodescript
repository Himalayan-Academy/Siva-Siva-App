script "behavior_mobileScroller"
local sMouseLoc
local sStacksHorizontal

######### Mobile Controls ############

command createScroller pName -- scrolling fields
   --set the acceleratedRendering of this stack to false
   local tRect
   if not isMobile() then exit CreateScroller
   deleteMobileControl pName -- delete any existing
   --PUT CR & CR &" " AFTER CONTROL PNAME 
   put (the rect of control pName) into tRect
   mobileControlCreate "scroller", pName
   mobileControlSet pName, "rect", tRect
   put ("0,0," & (the formattedwidth of control pName) & "," & \
         the formattedheight of control pName + 60) into tRect
   mobileControlSet pName, "contentRect", tRect
   mobileControlSet pName, "hScroll", 0
   mobileControlSet pName, "vScroll", 0
   mobileControlSet pName, "hIndicator", false
   if pName = "quote" then
      mobileControlSet pName, "vIndicator", true
   end if
   mobileControlSet pName, "visible",  true
end createScroller


on updateScroller pName
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
   if vScrolled < 20 then
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
   if not isMobile() then exit deleteMobileControl -- do nothing on desktop
   repeat while pName is among the lines of mobileControls()
      mobileControlDelete pName
   end repeat
   --set the acceleratedRendering of this stack to false --- jg: don't turn this off
end deleteMobileControl


on mouseDown
   if not isMobile() then -- jg: mobile will use stack handlers to scroll instead
      put the mouseloc into sMouseLoc
      setScroll
   end if
   pass mousedown
end mouseDown


on setScroll
   if the mouse is down then
      lock screen
    
        if abs (item 2 of sMouseLoc ) > 20 then
         if item 2 of sMouseLoc > the mouseV then
            set the vscroll of me to the vscroll of me - (the mouseV - item 2 of sMouseLoc)
         else
            set the vscroll of me to the vscroll of me + (item 2 of sMouseLoc - the mouseV)
         end if
         put the mouseloc into sMouseLoc
      end if
      send "setScroll" to me in 20 millisec
      unlock screen
   else
      put empty into sMouseLoc
   end if
end setScroll
