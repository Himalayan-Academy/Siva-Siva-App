script "mobileScroller"


######### Mobile Controls ############

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
  if pName = "quote" then
     mobileControlSet pName, "vIndicator", true
  end if
  mobileControlSet pName, "visible",  true
end CreateScroller

on scrollerDidScroll hScrolled, vScrolled
  put mobileControlTarget() into tControlID
  set the vscroll of control tControlID to vscrolled
  pass scrollerDidScroll
end scrollerDidScroll

on deleteMobileControl pName -- jg: deletes an existing mobile control
  -- native controls should be deleted if possible when no longer needed, as
  -- they are overlaid on the stack and will float over all cards
  if not isMobile() then exit deleteMobileControl -- do nothing on desktop
  repeat while pName is among the lines of mobileControls()
    mobileControlDelete pName
  end repeat
end deleteMobileControl
