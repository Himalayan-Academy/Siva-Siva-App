Script "stack_stories_group_id_1449"

/*
# Name: group "ToolGroup" of card "colorIt" of stack "stories"
# ID: group id 1449 of card id 1421 of stack "stories"
*/


on updateUI
   set the width of me to CardWidth()
   bottomCenterMe (the long id of me), -safeBottomMargin()
end updateUI


on resizeControl
   local tHSpace, tV, tH, tControl, tRect, tButtons
   put "select,pencil,brush,eraser,spray can,bucket,line" into tButtons
   put the width of me / (the number of items in tButtons) into tHSpace
   put item 2 of the loc of button 1 of grp "Icons" of me into tV
   put the left of me + (tHSpace / 2) into tH
   --
   repeat for each item tName in tButtons
      put the long name of btn tName of grp "Icons" of me into tControl
      --set the width of tControl to tHSpace
      set the loc of tControl to (tH, tV)
      add tHSpace to tH
   end repeat
   --
   set the height of me to 120 + safeBottomMargin()
   set the bottom of me to CardHeight()
   set the rect of grc "colorItBg" to the rect of me
end resizeControl

