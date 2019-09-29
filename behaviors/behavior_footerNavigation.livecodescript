script "behavior_footerNavigation"
global sConfigA
local sButtons

on preOpenControl
   local tStack
   put the short name of this stack into tStack
   if tStack is "gems" or tStack is "lib_CustomControls" then
      put "home,journal,save,share,settings" into sButtons
   else
      put "home,journal,share,settings" into sButtons
      hide btn "save" of me
      send "resizeControl" to me
   end if
end preOpenControl

on mouseup
   local tTarget, tShareControl, tControl, tCard
   local tBrowserExists, tBrowser, tBrowserRect
   local tCdHeight, tSharingHeight
   
   lock screen
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
         put the short name of this card into tCard
         --lock screen
         if tCard is "surprise_verse" then
            go to card "surprise_verses"
         else if tCard is "Surprise" and \
               there is a card "Home" then
            --set the visible of me to false
            go to card "Home"
         else
            portal_GoStack ("Siva-Siva-Portal")
         end if
         --unlock screen
         break
         
      case "journal"
         portal_GoStack "Journal"
         break
         
      case "save"
         AddJournalEntry "pReadQuote"
         unlock screen
         set the hilited of control tTarget to true
         move control target relative 0,-100 in 500 milliseconds
         move control target relative 0,100 in 110 milliseconds
         send "unHiliteBtn tTarget" to me in 1 seconds
         break
         
      case "share"
         --lock screen
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
         --unlock screen
         break
         
      case "settings"
         portal_GoStack "settings"
         break
   end switch
   unlock screen
end mouseup


command unHiliteBtn pTarget
   set the hilited of control pTarget to false
end unHiliteBtn


on resizeControl
   local tHSpace, tV, tH, tControl
   put the width of me / (the number of items in sButtons) into tHSpace
   put item 2 of the loc of me into tV
   put the left of me + (tHSpace / 2) into tH
   
   repeat for each item tName in sButtons
      put the long name of btn tName of me into tControl
      set the width of tControl to tHSpace
      set the loc of tControl to (tH, tV)
      add tHSpace to tH
   end repeat
   
   set the rect of grc "footerBackground" to the rect of me
end resizeControl

