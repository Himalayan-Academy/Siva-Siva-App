script "mobileScroller"
local sMouseLoc, sStartLoc,
on mouseDown
  put the mouseloc into sMouseLoc
  put sMouseLoc into sStartLoc
  if not isMobile() then -- jg: mobile will use stack handlers to scroll instead
    setScroll
  end if
end mouseDown

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

command CreateScroller pName -- scrolling regions,groups, fields
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
   mobileControlSet pName, "visible",  true
end CreateScroller

on scrollerDidScroll hScrolled, vScrolled
  put mobileControlTarget() into tControlID
  set the vscroll of control tControlID to vscrolled
  pass scrollerDidScroll
end scrollerDidScroll

