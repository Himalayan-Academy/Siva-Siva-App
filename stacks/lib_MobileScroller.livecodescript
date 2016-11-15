script "lib_MobileScroller"

-- mobile scrollers --

command createScroller pName -- pass short name of control that should scroll
  if not isMobile() then exit CreateScroller
  deleteMobileControl pName -- delete any existing
  mobileControlCreate "scroller", pName
  mobileControlSet pName, "rect", (the rect of control pName)
  put  (0,0,the formattedwidth of control pName,the formattedheight of control pName) into tRect
  mobileControlSet pName, "contentRect" , tRect
  mobileControlSet pName, "hScroll" , 0
  mobileControlSet pName, "vScroll" , 0
  mobileControlSet pName, "hIndicator" , false
  mobileControlSet pName, "vIndicator", true
  mobileControlSet pName, "visible",  true
end createScroller

on scrollerDidScroll hScrolled, vScrolled
  put mobileControlTarget() into tControlID
  set the vScroll of control tControlID to vScrolled
end scrollerDidScroll 

on deleteMobileControl pName -- pass short name of control that should scroll
  if not isMobile() then exit deleteMobileControl -- do nothing on desktop
  repeat while pName is among the lines of mobileControls()
    mobileControlDelete pName
  end repeat
end deleteMobileControl

on deleteAllMobileControls -- delete all mobile controls of any type in all stacks
   if not isMobile() then exit deleteAllMobileControls
   put mobileControls() into tList
   repeat for each line l in tList
      mobileControlDelete l
   end repeat
 end deleteAllMobileControls