Script "stack_stories_group_id_1472"

/*
# Name: group "BrushIcons" of card "colorIt" of stack "stories"
# ID: group id 1472 of card id 1421 of stack "stories"
*/


on mouseUp
   local tTargetIcon
   --
   if the target contains "button" and the hilite of the target then
      put the icon of the target into tTargetIcon
      if the tool is "eraser tool" then
         --set the eraser to the number of the target
         set the eraser to tTargetIcon
      else if the tool is "spray tool" then
         --set the spray to the number of the target
         set the spray to tTargetIcon
      else
         --set the brush to the number of the target
         set the brush to tTargetIcon
      end if
      set the icon of btn "CurrentBrush" of grp "ToolGroup" of cd "ColorIt" to tTargetIcon
      hide me
   end if
end mouseUp

