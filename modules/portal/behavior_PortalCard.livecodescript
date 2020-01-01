script "behavior_PortalCard"
local sStartLoc,sScreenRect


on openCard
   local tLinksGroup, tControl, tRect, tFooter
   setCardCoords "portrait"
   portal_SetCurrentPortal (the short name of this card)
   audioIsRunning
   
   put the long id of grp "footerNavigation" into tFooter
   send "updateUI" to tFooter
   
   put "SivaSiva Portal Scrolling" into tLinksGroup
   put the long id of grp tLinksGroup into tControl
   topCenterMe tControl
   put the rect of tControl into tRect
   put the top of grp "footerNavigation" into item 4 of tRect
   set the rect of tControl to tRect
   send "CreateScroller tLinksGroup" to grp "SivaSiva Portal Scrolling" in 0 milliseconds
end openCard

on closeCard
   deleteAllMobileControls
end closeCard

on mouseDown
   put the mouseloc into sStartLoc
end mouseDown

on mouseUp
   local tRow, tLinkNo, tRowName
   # the text fld and image of each row are both disabled 
   # but have the naming convention of
   # 1_portal-link-bkgnd
   # 1_portal-link-label
   # 1_portal-link-image
   # we need to pass the text string in the label back 
   # to the navigation controller: lib_SivaSivaPortal 
   if isMobile() then
      mobileClearTouches
   end if
   if abs(the mouseH - item 1 of sStartLoc) <= 10 and abs(the mouseV - item 2 of sStartLoc) <= 10 then
      portal_setCurrentPortal(the short name of this card)
      put the short name of the target into tRow
      set the itemDelimiter to "_"
      put item 1 of tRow into tLinkNo
      if tLinkNo is not a number then
         exit mouseup
      end if
      put fld (tLInkNo &"_" &"portal-link-label") into tRowName
      replace cr with " " in tRowName
      --  put tRowName
      portal_DoRowLink tRowName
   end if
end  mouseup
