script "behavior_PortalInit"
local sMouseLoc, sStartLoc, sStartLocY,sStartLocX
local LocalArray

on preopencard
  set the scroll of grp "SivaSiva Portal Scrolling" to 0
end preopencard

on openCard
   portal_SetCurrentStack "Siva-Siva-Portal"
   portal_SetCurrent (the short name of this stack)
   show button "home-logo"
end openCard

on closeCard
   if isMobile() then
      dispatch "deleteMobileControl" to group "SivaSiva Portal Scrolling" with  "SivaSiva Portal Scrolling" 
   end if
end closecard

on mouseDown
   put the mouseloc into sMouseLoc
   put sMouseLoc into sStartLoc
end mouseDown

on mouseUp   
   put "" into sMouseLoc
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
      # note we note referencing David labyrinth of code to get the info from the JSON
      # maybe will later, but see no reason for it. our content is not changing every week 
      # we need to pass an explicit string in the form of
      # go stack xxxx  OR
      # go card yyyy of stack xxx
      portal_DoRowLink tRowName
   end if
   
end  mouseup


