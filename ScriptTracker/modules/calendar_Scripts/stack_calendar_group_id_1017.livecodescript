Script "stack_calendar_group_id_1017"

/*
# Name: group "main-calendar-view" of card "main-calendar" of stack "calendar"
# ID: group id 1017 of card id 1002 of stack "calendar"
*/


on resizeControl
   local tRect
   put (the left of me + 4, the top of me + 4, \
         the right of me - 4, the bottom of me - 4) into tRect
   set the rect of fld "current_days" of me to tRect
   
   put (the left of me + 7, the top of me + 9, \
         the right of me - 7, the bottom of me - 31) into tRect
   set the rect of fld "allDataForOneDay" of me to tRect
   
   put (the left of me + 257, the bottom of me - 29, \
         the right of me - 1, the bottom of me + 8) into tRect
   set the rect of grp "resizeFonts" of me to tRect
end resizeControl

