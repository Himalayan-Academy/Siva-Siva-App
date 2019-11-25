Script "stack_calendar_field_id_1015"

/*
# Name: field "current_days" of group "main-calendar-view" of card "main-calendar" of stack "calendar"
# ID: field id 1015 of group id 1017 of card id 1002 of stack "calendar"
# Behavior: stack "behavior_mobileScroller"
*/



local sStartLoc

on mouseDown
   put the mouseloc into sStartLoc
   pass mouseDown -- to behavior
end mouseDown

on mouseUp
   local tDayNum, tCalendar, tDailyInfo
   if abs(the mouseH - item 1 of sStartLoc) <= 10 and abs(the mouseV - item 2 of sStartLoc) <= 10 then -- a tap
      put the metadata of the clickline into tDayNum
      put tDayNum
      if tDayNum < 1 then exit mouseup
      put getCalendarDayInfo(tDayNum) into tCalendar
      put tCalendar["allDayData"] into fld "allDataForOneDay"
      show fld "allDataForOneDay"
      hide fld "current_days"
      put "allDataForOneDay" into tDailyInfo
      send "CreateScroller tDailyInfo" to fld "allDataForOneDay"
      show grp "resizeFonts"
   end if
end  mouseup
