Script "stack_color-meditation_bkgnd_id_1035"

/*
# Name: bkgnd "colorMedsToolbar" of stack "color-meditation"
# ID: bkgnd id 1035 of stack "color-meditation"

# Background on card IDs: 1019, 1075, 1066, 1023
*/


on resizeControl
   local tHSpace, tV, tH, tControl
   put the width of me / 4 into tHSpace
   put item 2 of the loc of me into tV
   put the left of me + tHSpace into tH
   
   put the long id of btn "getInfo" of me into tControl
   set the loc of tControl to (tH, tV)
   add tHSpace to tH
   
   put the long id of grc "Start" of me into tControl
   set the loc of tControl to (tH, tV)
   add tHSpace to tH
   
   put the long id of grp "colorSetting" of me into tControl
   set the loc of tControl to (tH, tV)
end resizeControl

