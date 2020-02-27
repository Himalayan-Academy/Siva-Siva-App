Script "stack_pathtosiva_button_id_1251"

/*
# Name: button "mobileScrollerBehavior" of card "cover" of stack "pathtosiva"
# ID: button id 1251 of card id 1088 of stack "pathtosiva"
*/



-- creation and management of mobile scrollers --
-- behavior assigned to stack --
local tRect,tControlID,sStacksHorizontal

command createScroller pName
  if not isMobile() then exit createScroller
  deleteMobileControl pName -- delete any existing
  --   set the vScroll of control pName to 0 -- init for alignment
  mobileControlCreate "scroller", pName
  mobileControlSet pName, "rect", (the rect of control pName)
  put  (0,0,the formattedwidth of control pName,the formattedheight of control pName+ 60) into tRect
  mobileControlSet pName, "contentRect",tRect
  mobileControlSet pName, "hScroll",0
  wait 0 milliseconds -- workaround for mobile vscroll bug
  mobileControlSet pName, "vScroll", 0 
  mobileControlSet pName, "hIndicator",false
  mobileControlSet pName, "vIndicator",true
  mobileControlSet pName, "visible", true
end createScroller

on scrollerDidScroll hScrolled, vScrolled
   put mobileControlTarget() into tControlID
   if  vScrolled < 2 then
      set the vscroll of control tControlID to 0 --vscrolled 	
   else
      set the vscroll of control tControlID to vscrolled + 20
   end if
   if  short name of this stack is among the items of sStacksHorizontal then
      set the hscroll of control tControlID to hScrolled
   end if
   
end scrollerDidScroll

--on scrollerDidScroll tHScroll, tVScroll
--  put mobileControlTarget() into tControlID
--  set the vScroll of control tControlID to tVScroll+40
--end scrollerDidScroll 

on deleteMobileControl pName -- deletes an existing mobile control
  if not isMobile() then exit deleteMobileControl -- do nothing on desktop
  repeat while pName is among the lines of mobileControls()
    mobileControlDelete pName
  end repeat
end deleteMobileControl

on deleteCardMobileControls -- delete all mobile controls of any type on current card only
  if not isMobile() then exit deleteCardMobileControls
  repeat for each line l in mobileControls()
    if there is a grp l then
      mobileControlDelete l
    end if
  end repeat
end deleteCardMobileControls


