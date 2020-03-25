script "behavior_PortalCard"
local sStartLoc,sScreenRect


on openCard
   local tLinksGroup, tControl, tRect, tFooter
   setCardCoords "portrait"
  
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
   local tRow, tLinkNo, tCard
   
   if abs(the mouseH - item 1 of sStartLoc) <= 10 and abs(the mouseV - item 2 of sStartLoc) <= 10 then
      
      put the short name of the target into tRow
      set the itemDelimiter to "_"
      put item 1 of tRow into tCard
      
      if tCard = "Video" then
         getRandomVideo
      end if
      go to card ("surprise_" & tCard)
   end if
end  mouseup
