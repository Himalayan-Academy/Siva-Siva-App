Script "stack_calendar_group_id_1127"

/*
# Name: group "resizeFonts" of group "main-calendar-view" of card "main-calendar" of stack "calendar"
# ID: group id 1127 of group id 1017 of card id 1002 of stack "calendar"
*/


on mouseup
   local tResizeText
   if the vis of fld "AllDataForOneDay" is true then
      put the long id fld "AllDataForOneDay" into tResizeText
      if the textSize of  tResizeText  = 28 then
         set the textSize of tResizeText to 18
      else
         set the textsize of tResizeText  to (the textsize of tResizeText  + 2)
      end if
   end if
end mouseup
