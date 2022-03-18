Script "stack_stories_group_id_1539"

/*
# Name: group "footer" of card "colorIt" of stack "stories"
# ID: group id 1539 of card id 1421 of stack "stories"
*/


constant kButtons = "eraser,bucket,fillColor"
# select,pencil,brush,eraser,spray can,bucket,line

local sStarted


on mouseUp
   local tTarget, tBrushIcon
   --
   put the short name of the target into tTarget
   --
   if tTarget is among the items kButtons then
      dispatch "deleteMobileControl" to grp "colorItImageGroup" with "colorItImageGroup"
   end if
   --
   --   if tTarget is "eraserIcon" then
   --      set the layer of grp "BrushIcons" of cd "colorIt" to 99
   --      show grp "BrushIcons" of cd "colorIt"
   --   end if
   if tTarget is "fillColor" then
      show control "Color map"
   end if
   --
   if tTarget is among the items "eraser,bucket" then
      put false into sStarted
      relayer getColorItImage() to back of cd "colorIt"
      setColorItImage (the long id of img "colorItImage")
      send "checkLoc" to me in 50 milliseconds
      choose "bucket" tool
   end if
   --
   if tTarget is "bucket" then
      set the brushColor to the backgroundColor of btn "fillColor"
   else
      set the brushColor to "white"
   end if
   --
   --   if the tool is "eraser tool" then
   --      set the eraser to the icon of btn "eraserIcon"
   --   else if the tool is "bucket tool" then
   --      set the brushColor to the backgroundColor of btn "fillColor"
   --   end if
end mouseUp

on checkLoc
   if item 2 of the mouseloc < item 2 of the rect of grp "footer" of cd "colorIt" then
      put true into sStarted
   end if
   if sStarted then
      if the mouseloc is within the rect of grp "footer" of cd "colorIt" or \
            item 2 of the mouseloc < item 4 of the rect of btn "save" of cd "colorIt" then
         choose the browse tool
         put false into sStarted
         relayer getColorItImage() to front of grp "colorItImageGroup"
         setColorItImage (the long id of img "colorItImage")
         dispatch "createImageScroller" to grp "colorItImageGroup" with "colorItImageGroup"
         exit "checkLoc"
      end if
   end if
   send "checkLoc" to me in 50 milliseconds
end checkLoc


on updateUI
   set the width of me to CardWidth()
   bottomCenterMe (the long id of me), -safeBottomMargin()
end updateUI


on resizeControl
   local tHSpace, tV, tH, tControl, tRect
   --
   put the width of me / (the number of items in kButtons) into tHSpace
   put item 2 of the loc of button 1 of me into tV
   put the left of me + (tHSpace / 2) into tH
   --
   repeat for each item tName in kButtons
      put the long name of btn tName of me into tControl
      set the loc of tControl to (tH, tV)
      add tHSpace to tH
   end repeat
   --
   set the height of me to 50 + safeBottomMargin()
   set the bottom of me to CardHeight()
   set the rect of grc "footerBackground" to the rect of me
end resizeControl


on preOpenControl
   set the icon of btn "eraserIcon" to 102
   set the backgroundColor of btn "fillColor" to "red"
end preOpenControl
