script "behavior_mobileScroller"
local sMouseLoc

######### Mobile Controls ############

command CreateScroller pName -- scrolling fields
   --set the acceleratedRendering of this stack to false
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
   if pName = "quote" then
      mobileControlSet pName, "vIndicator", true
   end if
   mobileControlSet pName, "visible",  true
end CreateScroller

on scrollerDidScroll hScrolled, vScrolled
   put mobileControlTarget() into tControlID
   set the vscroll of control tControlID to vscrolled
   set the hscroll of control tControllD to hScrolled
   -- pass scrollerDidScroll -- jg: don't pass, it blocks scrolling when there are nested behaviors
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
      
      if abs (item 1 of sMouseLoc) > 20 then
         if item 1 of sMouseLoc > the mouseH then
            set the hscroll of me to the hscroll of me - (the mouseH - item 1 of sMouseLoc)
         else
            set the hscroll of me to the hscroll of me + (item 1 of sMouseLoc - the mouseH)
         end if
         put the mouseloc into sMouseLoc
      end if
      
      send "setScroll" to me in 20 millisec
      unlock screen
   else
      put empty into sMouseLoc
   end if
end setScroll

-- on mouseMove pNewHeight, pNewWidth
--    if not isMobile() then -- jg: mobile will use stack handlers to scroll instead
--       setScroll pNewHeight, pNewWidth
--    end if
-- end mouseMove

-- on setScroll pNewHeight, pNewWidth
--    lock screen
--    if abs (pNewHeight-item 2 of sMouseLoc ) > 20 then
--       set the vscroll of me to pNewHeight
--       exit to top
--    end if
--    if abs (pNewWidth-item 1 of sMouseLoc ) > 20 then
--       set the hScroll of me to pNewWidth
--       exit to top
--    end if      
--    unlock screen  
-- end setScroll

