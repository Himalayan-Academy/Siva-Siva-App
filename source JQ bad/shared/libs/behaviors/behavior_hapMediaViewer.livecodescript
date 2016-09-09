script "behavior_hapMediaViewer"

command createBrowserWidget pOrientation
   create invisible widget "Browser" as "com.livecode.widget.browser"
   if pOrientation = "portrait" then
      set the rect of widget "browser" to the 0,30,(the width of this stack),(the height of this stack-50)
   else
      set the rect of widget "browser" to the 50,30,(the width of this stack),(the height of this stack)
   end if
   show widget "Browser"
end createBrowserWidget


// PRIVATE ROUTINES BELOW

-- command closeStopCloseGoRecent
--   # for now we assume if we close this stack the previous stack will still be open underneath
--   --   delete widget "Browser"
--   --   close me

--   --   if (exists (widget pBrowserName) ) then
--   --      delete widget pBrowserName
--   --   end if
--   --   go recent
-- end closeStopCloseGoRecent
