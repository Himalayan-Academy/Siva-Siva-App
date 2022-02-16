Script "stack_stories_group_id_1453"

/*
# Name: group "Icons" of group "ToolGroup" of card "colorIt" of stack "stories"
# ID: group id 1453 of group id 1449 of card id 1421 of stack "stories"
*/


local sStarted

on mouseUp
   local tTarget, tBrushIcon
   --
   put the short name of the target into tTarget
   put the icon of btn "CurrentBrush" of grp "ToolGroup" of cd "ColorIt" into tBrushIcon
   --
   if word 1 of the name of the target is "button" then
      put false into sStarted
      send "checkLoc" to me in 50 milliseconds
      choose tTarget tool
   end if
   --
   if the tool is "eraser tool" then
      set the eraser to tBrushIcon
   else if the tool is "spray tool" then
      set the spray to tBrushIcon
      set the brushColor to "green"
   else if the tool is "brush tool" then
      set the brush to tBrushIcon
      set the brushColor to "red"
   else
      set the penColor to "blue"
   end if
end mouseUp

on checkLoc
   if item 2 of the mouseloc < item 2 of the rect of grp "ToolGroup" of cd "colorIt" then
      put true into sStarted
   end if
   if sStarted then
      if the mouseloc is within the rect of grp "ToolGroup" of cd "colorIt" or \
            item 2 of the mouseloc < item 4 of the rect of btn "save" of cd "colorIt" then
         choose the browse tool
         put false into sStarted
         clearHighlight
         exit "checkLoc"
      end if
   end if
   send "checkLoc" to me in 50 milliseconds
end checkLoc
