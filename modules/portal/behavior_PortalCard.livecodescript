script "behavior_PortalCard"
local sStartLoc,sScreenRect

on openCard
   local tLinksGroup, tControl, tRect, tFooter
   setCardCoords "portrait"
   portal_SetCurrentPortal (the short name of this card)
   audioIsRunning
   
   put the long id of grp "footerNavigation" into tFooter
   set the width of tFooter to CardWidth()
   bottomCenterMe tFooter

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


--command layoutNavBar
--   local tWidth, tBottom, tHorzFour, tHorzThree, tHorzTwo, tControl
--   put cardWidth() into tWidth
--   put cardHeight() - safeBottomMargin() - 25 into tBottom
--   --put item 3 of (the rect of this card)  into tWidth
--   --put item 4 of (the rect of this card)-25 into tBottom

--   --put item 3 of sScreenRect into tWidth
--   --put item 4 of sScreenRect-25 into tBottom
--   --

--   -- BWM: this method will not take into account side safe margins
--   put round(tWidth/8) into tHorzFour
--   put round(tWidth/6) into tHorzThree
--   --put round(tWidth/4) into tHorzTwo

--   put the long id of grp "SivaSiva Portal Navigation" into tControl
--   bottomCenterMe tControl

--   Switch (the short name of this card)
--      case "Home"
--         # hide home
--         hide widget "go-home-portal"
--         set the loc of widget "add-favorites" to tHorzThree,tBottom
--         set the loc of widget "share" to tHorzThree*3,tBottom
--         set the loc of widget "settings-gear" to tHorzThree*5,tBottom
--         break
--      default
--         show widget "go-home-portal"
--         set the loc of widget "go-home-portal" to tHorzFour,tBottom
--         set the loc of widget "add-favorites" to tHorzFour*3,tBottom
--         set the loc of widget "share" to tHorzFour*5,tBottom
--         set the loc of widget "settings-gear" to tHorzFour*7,tBottom
--   end switch

--end  layoutNavBar
