Script "stack_pathtosiva_button_id_1251"

/*
# Name: button "mobileScrollerBehavior" of card "cover" of stack "pathtosiva"
# ID: button id 1251 of card id 1088 of stack "pathtosiva"
*/


----creation and management of mobile scrollers --
----behavior assigned to stack --
--local sStartVScroll, sIsScrolling, sLastVScroll
--constant kCheckScrollMS = 50

--command createScroller pName
--   local tRect
--   if not isMobile() then exit createScroller
--   deleteMobileControl pName -- delete any existing
--     set the vScroll of control pName to 0 -- init for alignment
--   mobileControlCreate "scroller", pName
--   mobileControlSet pName, "rect", (the rect of control pName)
--   put  (0,0,the formattedwidth of control pName,the formattedheight of control pName+ 60) into tRect
--   mobileControlSet pName, "contentRect",tRect
--   mobileControlSet pName, "hScroll",0
--   wait 0 milliseconds -- workaround for mobile vscroll bug
--   mobileControlSet pName, "vScroll", 0 
--   mobileControlSet pName, "hIndicator",false
--   mobileControlSet pName, "vIndicator",true
--   mobileControlSet pName, "visible", true
--   put 0 into sStartVScroll
--   put false into sIsScrolling
--end createScroller

--on scrollerDidScroll hScrolled, vScrolled
--   local tControlID
--   put mobileControlTarget() into tControlID
--   if  vScrolled < 20 then
--      set the vscroll of control tControlID to vScrolled * 2
--   else
--      set the vscroll of control tControlID to vScrolled + 20
--   end if
--   if not sIsScrolling then
--      put true into sIsScrolling
--      put vScrolled into sStartVScroll
--      put vScrolled into sLastVScroll
--      send "checkScrollDirection tControlID" to me in kCheckScrollMS milliseconds
--   end if
--end scrollerDidScroll

--on checkScrollDirection pControlID
--   local tCurrentVScroll
--   if not sIsScrolling then exit checkScrollDirection
--   put the vscroll of control pControlID into tCurrentVScroll
--   if tCurrentVScroll = sLastVScroll then
--      put false into sIsScrolling
--      exit checkScrollDirection
--   end if
--   put tCurrentVScroll into sLastVScroll
--   if tCurrentVScroll > sStartVScroll+30 then
--      dispatch "scrollingDown" to control pControlID
--   else if tCurrentVScroll < sStartVScroll-30 then
--      dispatch "scrollingUp" to control pControlID
--   else
--      send "checkScrollDirection pControlID" to me in kCheckScrollMS milliseconds
--      exit checkScrollDirection
--   end if
--   put false into sIsScrolling
--end checkScrollDirection

--on deleteMobileControl pName -- deletes an existing mobile control
--   if not isMobile() then exit deleteMobileControl -- do nothing on desktop
--   put false into sIsScrolling
--   repeat while pName is among the lines of mobileControls()
--      mobileControlDelete pName
--   end repeat
--end deleteMobileControl

--on deleteCardMobileControls -- delete all mobile controls of any type on current card only
--   if not isMobile() then exit deleteCardMobileControls
--   put false into sIsScrolling
--   repeat for each line l in mobileControls()
--      if there is a grp l then
--         mobileControlDelete l
--      end if
--   end repeat
--end deleteCardMobileControls


