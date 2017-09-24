script "behavior_PortalInit"
on preopencard
   set the scroll of grp "SivaSiva Portal Scrolling" to 0
end preopencard
on openCard
   wait 200 milliseconds
   set the acceleratedRendering of this stack to "true"
   put the long id of grp "SivaSiva Portal Scrolling" into scrollingView
   if the environment is "mobile" then
      set the mobile_VerticalScroller of scrollingView to "portal scroller"
   end if
   
   portal_SetCurrentStack "Siva-Siva-Portal"
   show button "home-logo"
   --  hide button "home-logo" with visual effect dissolve fast
   --pass openCard
end openCard

on closeCard
   if the environment is "mobile" then
      scroller_Delete "portal scroller"
   end if
end closeCard
