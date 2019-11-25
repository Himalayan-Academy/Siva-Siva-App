Script "stack_calendar_group_id_1103"

/*
# Name: group "headerGrp" of card "main-calendar" of stack "calendar"
# ID: group id 1103 of card id 1002 of stack "calendar"
*/


on resizeControl
   local tLoc
   
   set the rect of grc "backdrop" to the rect of me
   
   set the right of widget "locationSVG" to the right of me
   
   set the right of button "datePick" to the left of widget "locationSVG" - 8
   
   put the loc of fld "cityDisplay" into tLoc
   put item 1 of the loc of me into item 1 of tLoc
   set the loc of fld "cityDisplay" to tLoc
end resizeControl

