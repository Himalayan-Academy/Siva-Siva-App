Script "stack_stories_bkgnd_id_1539"

/*
# Name: bkgnd "footer" of stack "stories"
# ID: bkgnd id 1539 of stack "stories"

# Shared group on card IDs: 1421
*/


constant kButtons = "eraser,brush,bucket,fillColor"
constant kBucketColor = "#5FE49F"
constant kBrushColor = "#96E200"
constant kEraserColor = "#00EA63"
constant kHilightColor = "#FDBFFE"

local sStarted, sSaveTime, sTool

on mouseUp
   local tLongTarget, tTarget, tBrushIcon
   --
   if (the visible of control "Color map") or (the visible of grp "BrushIcons") then
      pass mouseUp
   end if
   --
   put the short name of the target into tTarget
   put the long id of the target into tLongTarget
   if tTarget is among the items kButtons then
      dispatch "deleteMobileControl" to grp "colorItImageGroup" with "colorItImageGroup"
   end if
   --
   if tTarget is "fillColor" then
      hide btn "cancel"
      hide btn "save"
      --
      show control "Color map"
      put empty into sTool
   else if tTarget is among the items "brush,bucket" then
      hide btn "cancel"
      hide btn "save"
      --
      pushImage
      put false into sStarted
      put tTarget into sTool
      relayer getColorItImage() to back of cd "colorIt"
      setColorItImage (the long id of img "colorItImage")
      send "checkLoc" to me in 50 milliseconds
      set the brushColor to the backgroundColor of grc "fillColor"
      set the backgroundColor of tLongTarget to kHilightColor
      if tTarget is "bucket" then
         choose "bucket" tool
      else
         choose "brush" tool
      end if
   else -- erase
      set the backgroundColor of tLongTarget to kHilightColor
      popImage
      makeImageDirty
      wait 750 milliseconds
      set the backgroundColor of tLongTarget to kEraserColor
   end if
end mouseUp


on checkLoc
   local tLandscape, tColor
   put currentlyLandscape() into tLandscape
   if (not tLandscape and item 2 of the mouseloc < item 2 of the rect of grp "footer" of cd "colorIt") \
         or (tLandscape and item 1 of the mouseloc > item 3 of the rect of grp "footer" of cd "colorIt") then
      if not sStarted then
         pushImage
         put the seconds + 5 into sSaveTime
      end if
      put true into sStarted
      makeImageDirty
   end if
   if sStarted then
      if the mouseloc is within the rect of grp "footer" of cd "colorIt" or \
            (not tLandscape and item 2 of the mouseloc < item 4 of the rect of btn "save" of cd "colorIt") then
         choose the browse tool
         put false into sStarted
         dropImageIfSame
         relayer getColorItImage() to front of grp "colorItImageGroup"
         setColorItImage (the long id of img "colorItImage")
         dispatch "createImageScroller" to grp "colorItImageGroup" with "colorItImageGroup"
         set the backgroundColor of btn "brush" of grp "footer" to kBrushColor
         set the backgroundColor of btn "bucket" of grp "footer" to kBucketColor
         show btn "cancel"
         show btn "save"
         exit "checkLoc"
      else
         if the seconds > sSaveTime then
            pushImage
            put the seconds + 5 into sSaveTime
         end if
      end if
   else
      if the mouse is down then
         if the mouseloc is within the rect of btn "brush" of me and sTool is "brush" then
            choose the browse tool
            set the layer of grp "BrushIcons" of cd "colorIt" to 99
            show grp "BrushIcons" of cd "colorIt"
            exit checkLoc
         else if the mouseloc is within the rect of grp "footer" of cd "colorIt" then
            put true into sStarted
         end if
      end if
   end if
   send "checkLoc" to me in 50 milliseconds
end checkLoc


on updateUI
   if currentlyLandscape() then
      set the height of me to CardHeight()
      set the topLeft of me to 0,0
   else
      set the width of me to CardWidth()
      bottomCenterMe (the long id of me), -safeBottomMargin()
   end if
end updateUI


on resizeControl
   local tHSpace, tVSpace, tV, tH, tControl, tRect
   --
   if currentlyLandscape() then
      put the height of me / (the number of items in kButtons) into tVSpace
      put the left of me + 26 + safeSideMargin() into tH
      put the top of me + (tVSpace / 2) into tV
      --
      repeat for each item tName in kButtons
         put the long name of btn tName of me into tControl
         set the loc of tControl to (tH, tV)
         add tVSpace to tV
      end repeat
      --
      set the width of me to 50 + safeSideMargin()
      set the left of me to 0
   else
      put the width of me / (the number of items in kButtons) into tHSpace
      put the top of me + 26 into tV
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
   end if
   --
   set the rect of grc "footerBackground" to the rect of me
   set the rect of grc "fillColor" to the rect of btn "fillColor"
end resizeControl


on preOpenControl
   set the icon of btn "toolIcon" to 102
   set the brush to 102
   set the hilite of button id 1474 to true
   set the backgroundColor of grc "fillColor" to "red"
end preOpenControl
