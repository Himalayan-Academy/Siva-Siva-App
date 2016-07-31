script "behavior_hapMediaViewer"

// PRIVATE ROUTINES BELOW

command closeStopCloseGoRecent pBrowserName
   if (exists (widget pBrowserName) ) then
      delete widget pBrowserName
      end if
   go recent
   close me
end closeStopCloseGoRecent

on createLandscapeBrowser
   create invisible widget "Browser"as "com.livecode.widget.browser"
   set the rect of widget "browser" to the 50,30,(the right of this card),(the bottom of this card)
end createLandscapeBrowser

--command initializeInterfaceDefaults pOrientation

--   if isMobile() then  -- jg
--      set the fullscreenmode of this stack to "showAll" -- better for wider screens
--      if the platform = "iphone" then
--         iphoneSetAudioCategory "playback" -- play when suspended or screen locked; Android doesn't need this
--      end if
--      if pOrientation ="portrait" then
--          mobileSetAllowedOrientations "portrait,portrait upside down" -- lock to both portrait orientations
--         set the width of this stack to 414
--         set the height of this stack to 736
--      else
--         mobileSetAllowedOrientations "landscape left,landscape right" -- lock to both portrait orientations
--       set the width of this stack to 736
--      set the height of this stack to 414
--      end if
--   else
--      set the dontUseQT to true --jg: only need this once on startup
--   end if

--end initializeInterfaceDefaults


private function dev -- Thanks to Jacqueline Landman Gay @ HyperActive Software for this one.
   return the environment is "development"
end dev

private function isMobile -- jg, for convenience
   return the environment is "mobile"
end isMobile


###### Orientation Change Ups
# There's got to be a better way to do this
# but for now this hack will work

private command setOrientation pObjects
   if the uOrientation of this card is "Landscape" then
      set the width of this stack to 736
      set the height of this stack to 414
      try
         set the top of widget "SivaBrowserLandscape" to 20
      end try
      
   else 
      set the width of this stack to 414
      set the height of this stack to 736
      try
         set the top of widget "SivaBrowserPortrait" to 20
      end try
   end if
   --set the loc of this stack to the screenloc
end setOrientation
