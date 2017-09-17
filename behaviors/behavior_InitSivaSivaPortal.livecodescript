script "behavior_InitSivaSivaPortal"


on preOpenStack
   -- start using this stack
   
   -- sivasiva_InitOrientation "portrait"
   set the fullscreenmode of this stack to "showAll" -- better for wider screens
   mobile_SetAllowedOrientation "portrait"
   
   put the portal_View of me into portalView
   _fixPortalBehavior portalView
   
   if the environment is "development" then
      set the rect of portalView to the rect of this card -- only useful for authoring
      set the portal_Name of portalView to "home"
   end if
   
   --pass preOpenStack
end preOpenStack

on openCard
   put the portal_View of me into portalView
   put the scrolling_View of me into scrollingView
   
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
   --pass closeCard
end closeCard

on reLaunch
   answer "went back to home module"
   --pass reLaunch
end reLaunch

private command _fixPortalBehavior portalView
   put the name of stack "behavior_ViewSivaSivaLayout" into bObject
   set the behavior of portalView to bObject -- just in case
   
   -- another hack to fix behaviors in case they are broken
   -- preOpenControl does not seem to always fix the issue of broken bahaviors
   dispatch "portal_InitBehaviors" to portalView
end _fixPortalBehavior
