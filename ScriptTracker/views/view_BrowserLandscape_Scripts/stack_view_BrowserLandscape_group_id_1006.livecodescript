Script "stack_view_BrowserLandscape_group_id_1006"

/*
# Name: group "footerNavigation" of card "SivaSivaBrowser" of stack "view_BrowserLandscape"
# ID: group id 1006 of card id 1002 of stack "view_BrowserLandscape"
*/


global sConfigA

on mouseUp
   local tTarget, tShareControl, tControl, tBrowser
   local tCdHeight, tSharingHeight, tParam, tWaitTime
   
   
   --tsNetLibUrlReuseConnection false # appear to work here... testing in lib_SivaSivaPortal
   
   put the short name of the target into tTarget
   
   --   if tTarget is not "share" then
   --      terminateBrowser
   --      show grc "blankImage"
   
   --      -- give time for connection to close before close the stack
   --      -- maybe to helps
   --      if isMobile() then
   --         if the platform is "iphone" then
   --            put 50 into tWaitTime
   --         else
   --            put 1 into tWaitTime
   --         end if
   --         wait tWaitTime milliseconds with messages
   --         mobileClearTouches
   --      end if
   --   end if
   
   switch tTarget
      case "go-home-portal"
         terminateBrowser
         lock screen
         portal_GoStack "Siva-Siva-Portal"
         unlock screen
         break
         
      Case "settings-gear"
         terminateBrowser
         portal_GoStack "settings"
         break
         
      case "share"
         lock screen
         put sConfigA["shareControl"] into tShareControl
         
         if (exists(group "share-ui" of this card) ) then
            -- it has a preopencontrol which hides me
         else
            copy tShareControl to this card 
         end if
         put the long id of group "share-ui" of this card into tControl
         put the long id of widget "body" of this card into tBrowser
         put the height of this card into tCdHeight
         put the height of tControl into tSharingHeight
         set loc of tControl to\
               (the width of this card/2),tCdHeight- (tSharingHeight/2 )
         set the top of tBrowser to -tSharingHeight
         
         deleteMobileControl  "audioPlayer"
         show group "share-ui" with visual "dissolve" very fast
         unlock screen
         break
         
      case "add-favorites"
         hide widget "Body"
         -- record the last URL they were on
         if not (the vis of widget "loader") then
            journal_AddEntry
         end if
         --wait 1 seconds with messages
         show widget "body"
         break
   end switch
end mouseup
