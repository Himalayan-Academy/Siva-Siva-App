script "behavior_PortalInit"
# behavior for each portal card

local sStartLoc,sScreenRect

on openCard 
   put getCardRect() into sScreenRect
   portal_SetCurrentStack "Siva-Siva-Portal"
   portal_SetCurrent (the short name of this card)
   audioIsRunning
   layoutNavBar
   put "SivaSiva Portal Scrolling" into tLinksGroup
   send "CreateScroller tLinksGroup" to grp "SivaSiva Portal Scrolling" in 0 milliseconds
end openCard
 
on mouseDown
      put the mouseloc into sStartLoc
end mouseDown

on mouseUp   
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
      portal_setCurrent (the short name of this card)
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

command layoutNavBar
   put item 3 of sScreenRect into tWidth
   put item 4 of sScreenRect-25 into tBottom
   
   
   put round(tWidth/8) into tHorzFour
   put round(tWidth/6) into tHorzThree
   put round(tWidth/4) into tHorzTwo
   
   Switch (the short name of this card)
      case "Home"
         # hide home
         hide widget "go-home-portal"
         set the loc of widget "add-favorites" to tHorzThree,tBottom
         set the loc of widget "share" to tHorzThree*3,tBottom
         set the loc of widget "settings-gear" to tHorzThree*5,tBottom
         break
      default
         show widget "go-home-portal"
         set the loc of widget "go-home-portal" to tHorzFour,tBottom
         set the loc of widget "add-favorites" to tHorzFour*3,tBottom
         set the loc of widget "share" to tHorzFour*5,tBottom
         set the loc of widget "settings-gear" to tHorzFour*7,tBottom
   end switch
   
end  layoutNavBar


