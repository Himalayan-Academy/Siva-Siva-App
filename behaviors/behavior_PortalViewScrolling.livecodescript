script "behavior_PortalViewScrolling"
--> MetaData
-
license: GPLv3
name: behavior_PortalViewScrolling
type: behavior
version: 0.2
deps: function portal_GetArray

/*
Cloned and customised many of the LayoutControl handlers from "behavior_ViewLayoutVertical"
The "behavior_ViewLayoutVertical" behavior can be added to add some extra functionality.
But it should work without "behavior_ViewLayoutVertical"
*/


--> Variables

local sMouseLoc, sStartLoc, sStartLocY,sStartLocX
local LocalArray
--> Working on
on preopenControl
   wait 200 milliseconds
   CreateScroller "SivaSiva Portal Scrolling"
end preopenControl



--> Events

on mouseUp   
   # the text fld and image of each row are both disabled 
   # but have the naming convention of
   # 1_portal-link-bkgnd
   # 1_portal-link-label
   # 1_portal-link-image
   # we need to pass the text string in the label back 
   # to the navigation controller: lib_SivaSivaPortal 
   portal_setCurrent (the short name of this card)
   put the short name of the target into tRow
   set the itemDelimiter to "_"
   put item 1 of tRow into tLinkNo
   if tLinkNo is not a number then
      exit mouseup
   end if
   put fld (tLInkNo &"_" &"portal-link-label") into tRowName
   replace cr with " " in tRowName
   # note we note referencing David labyrinth of code to get the info from the JSON
   # maybe will later, but see no reason for it. our content is not changing every week 
   # we need to pass an explicit string in the form of
   # go stack xxxx  OR
   # go card yyyy of stack xxx
   portal_DoRowLink tRowName
end  mouseup

--on mouseDown
--   if the environment is "mobile" then
--      -- mobile will use stack handlers to scroll instead
--   else
--      put the mouseloc into sMouseLoc
--      put sMouseLoc into sStartLoc
--      put item 1 of sStartLoc into sStartLocX
--      put item 2 of sStartLoc into sStartLocY
--      desktop_SetScroll
--   end if
--   pass mouseDown
--end mouseDown

private function _mouseMoved
   put abs (the mouseV - item 2 of sStartLoc) into someDistance
   put someDistance >= 10 into someBoolean
   return someBoolean
end _mouseMoved

