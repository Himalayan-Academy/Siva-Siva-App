Script "stack_color-meditation_bkgnd_id_1009"

/*
# Name: bkgnd "contentCardHeader" of stack "color-meditation"
# ID: bkgnd id 1009 of stack "color-meditation"

# Background on card IDs: 1019, 1075, 1066, 1023, 1026, 1002
*/


on resizeControl
   local tControl
   
   put the long id of btn "back-arrow" of me into tControl
   set the left of tControl to the left of me + 1
   set the top of tControl to the top of me + 3
   
   put the long id of fld "Title" of me into tControl
   set the loc of tControl to the loc of me
   
   set the rect of grc "portal-title-bkgnd" of me to the rect of me
end resizeControl

