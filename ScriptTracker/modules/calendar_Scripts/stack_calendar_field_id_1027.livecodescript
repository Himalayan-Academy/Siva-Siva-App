Script "stack_calendar_field_id_1027"

/*
# Name: field "allDataForOneDay" of group "main-calendar-view" of card "main-calendar" of stack "calendar"
# ID: field id 1027 of group id 1017 of card id 1002 of stack "calendar"
# Behavior: stack "behavior_mobileScroller"
*/



local sStartLoc

on mouseDown
   put the mouseloc into sStartLoc
   pass mouseDown -- to behavior
end mouseDown

on mouseUp  
   if abs(the mouseH - item 1 of sStartLoc) <= 10 and abs(the mouseV - item 2 of sStartLoc) <= 10 then -- a tap
      deleteMobileControl the short name of me
      hide me
      hide grp "resizeFonts"
   end if
end  mouseup
