Script "stack_calendar_field_id_1048"

/*
# Name: field "YearList" of group "city-picker-view" of card "main-calendar" of stack "calendar"
# ID: field id 1048 of group id 1014 of card id 1002 of stack "calendar"
# Behavior: stack "behavior_mobileScroller"
*/



local sMouseLoc,sStartLoc

on mouseDown
   put the mouseloc into sMouseLoc
   put sMouseLoc into sStartLoc
end mouseDown

on mouseUp -- not sent on mobile when swiping, works on taps
   local tHDist, tVDist
   put "" into sMouseLoc
   put abs(the mouseH - item 1 of sStartLoc) into tHDist
   put abs(the mouseV - item 2 of sStartLoc) into tVDist
   if tHDist <= 10 and tVDist <= 10 then -- a tap
      send "doScrollerTap" to me in 0
   end if 
end  mouseup

on mouseRelease
   put "" into sMouseLoc
   put "" into sStartLoc
end mouseRelease

on mouseMove x,y -- desktop scrolling
   local tVDist
   if isMobile() or sMouseLoc = "" then pass mouseMove -- to mobileScrollerBehavior
   if sMouseLoc = "" then pass mouseMove
   put abs(y - item 2 of sMouseLoc) into tVDist
   if item 2 of sMouseLoc > y then -- pushing up
      set the vscroll of me to the vscroll of me + tVDist
   else if item 2 of sMouseLoc < y then -- pushing down
      set the vscroll of me to the vscroll of me - tVDist
   end if
   put x,y into sMouseLoc
end mouseMove

command doScrollerTap
   local tYear
   if the text of the clickline = "" then exit to top
   set the hilitedline of me to word 2 of the clickline
   wait 5
   put the clicktext into tYear
   put tYear into fld "yearName"
   set the hilitedline of me to 0
   showYearList false
end doScrollerTap
