Script "stack_stories_group_id_1453"

/*
# Name: group "Icons" of group "ToolGroup" of card "colorIt" of stack "stories"
# ID: group id 1453 of group id 1449 of card id 1421 of stack "stories"
*/


on mouseUp
   local tTarget
   --
   put the short name of the target into tTarget
   --
   if word 1 of the name of the target is "button" then
      choose tTarget tool
   end if
   --
   if the tool is "eraser tool" then
      --set the eraser to the number of the target
      --set the eraser to 108
   else if the tool is "spray tool" then
      --set the spray to the number of the target
      --set the spray to 108
      set the brushColor to "green"
   else if the tool is "brush tool" then
      --set the brush to the number of the target
      --set the brush to 108
      set the brushColor to "red"
   else
      set the penColor to "blue"
   end if
end mouseUp
