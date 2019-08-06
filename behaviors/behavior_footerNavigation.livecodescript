script "behavior_footerNavigation"
global sConfigA
constant kButtons = "home,journal,share,settings"

on mouseup
   local tTarget, tShareControl, tControl
   local tBrowserExists, tBrowser, tBrowserRect
   local tCdHeight, tSharingHeight
   
   put short name of the target into tTarget
   put (there is a widget "body") into tBrowserExists
   
   if tBrowserExists then
      if not (the vis of widget "loader") then
         -- record the last URL they were on
         journal_AddEntry
      end if
      if tTarget is not "share" then
         terminateBrowser
      end if
   end if
   
   switch tTarget
      case "home"
         if the short name of this card is "surprise_verse" then
            go to card "surprise_verses"
         else
            lock screen
            portal_GoStack ("Siva-Siva-Portal")
            unlock screen
         end if
         break
         
      case "journal"
         portal_GoStack "Journal"
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
         if tBrowserExists then
            put the long id of widget "body" of this card into tBrowser
            put the rect of tBrowser into tBrowserRect
            put the top of tControl into item 4 of tBrowserRect
            set the rect of tBrowser to tBrowserRect
         end if
         
         deleteMobileControl  "audioPlayer"
         show group "share-ui" with visual "dissolve" very fast
         unlock screen
         break
         
      case "settings"
         portal_GoStack "settings"
         break
   end switch
end mouseup


command unHiliteBtn pTarget
   set the hilited of control ptarget to false
end unHiliteBtn


on resizeControl
   local tHSpace, tV, tH, tControl
   put the width of me / 4 into tHSpace
   put item 2 of the loc of me into tV
   put the left of me + (tHSpace / 2) into tH
   
   repeat for each item tName in kButtons
      put the long name of widget tName of me into tControl
      set the width of tControl to tHSpace
      set the loc of tControl to (tH, tV)
      put the long name of grc tName of me into tControl
      set the width of tControl to tHSpace
      set the loc of tControl to (tH, tV)
      add tHSpace to tH
   end repeat
   
   set the rect of grc "footerBackground" to the rect of me
end resizeControl

