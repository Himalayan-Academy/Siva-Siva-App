Script "stack_view_SivaSivaBrowser_group_id_1006"

/*
# Name: group "footerNavigation" of card "SivaSivaBrowser" of stack "view_SivaSivaBrowser"
# ID: group id 1006 of card id 1002 of stack "view_SivaSivaBrowser"
*/


global sConfigA

on mouseUp

   local tTarget, tShareControl, tControl, tBrowser, tBrowserRect
   local tCdHeight, tSharingHeight
   
   
   
   put the short name of the target into tTarget
   
   if tTarget is not "add-favorites" then
      terminateBrowser
      show grc "blankImage"
      wait 10 milliseconds with messages
   end if
   
   switch tTarget
      case "go-home-portal"
         lock screen
         portal_GoStack ("Siva-Siva-Portal")
         unlock screen
         break
         
      Case "settings-gear"
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
         bottomCenterMe tControl, -safeBottomMargin()
         put the long id of widget "body" of this card into tBrowser
         put the rect of tBrowser into tBrowserRect
         put the top of tControl into item 4 of tBrowserRect
         set the rect of tBrowser to tBrowserRect
         
         deleteMobileControl  "audioPlayer"
         show group "share-ui" with visual "dissolve" very fast
         unlock screen
         break
         
      case "add-favorites"
         -- record the last URL they were on
         if not (the vis of widget "loader") then
            journal_AddEntry
         end if
         break
   end switch
end mouseup
