Script "stack_color-meditation_group_id_1162"

/*
# Name: group "prefsSelectorGrp" of card "colorPreferences" of stack "color-meditation"
# ID: group id 1162 of card id 1023 of stack "color-meditation"
*/


on resizeControl
   local tControl, tWidth, tHeight
   
   put the width of me into tWidth
   put the height of me into tHeight
   
   put the long id of fld "prefsSelector" of me into tControl
   set the width of tControl to tWidth - 55
   set the height of tControl to tHeight - 30
   set the loc of tControl to the loc of me
   
   set the rect of grc "selectorBkgnd" of me to the rect of me
end resizeControl

