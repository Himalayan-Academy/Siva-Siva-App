script "behavior_PortalInit"
local sStartLoc

on preopencard
  set the scroll of grp "SivaSiva Portal Scrolling" to 0
end preopencard

on openCard
   portal_SetCurrentStack "Siva-Siva-Portal"
   portal_SetCurrent (the short name of this stack)
   show button "home-logo"
   put "SivaSiva Portal Scrolling" into tLinksGroup
   send "CreateScroller tLinksGroup" to grp "SivaSiva Portal Scrolling" in 100 milliseconds
 end openCard
 
on closecard
   dispatch "deleteMobileControl" to grp "SivaSiva Portal Scrolling" with "SivaSiva Portal Scrolling"
end closecard

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
    portal_DoRowLink tRowName
  end if
end  mouseup
