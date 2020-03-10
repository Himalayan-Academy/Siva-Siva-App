script "behavior_footerNavigation"
global sConfigA
local sButtons

on preOpenControl--
   --breakpoint
   local tStack
   put the short name of this stack into tStack
   switch tStack
      case "gems"
         put "home,save,share,settings" into sButtons
         break
      case "lib_CustomControls" 
         put "home,journal,save,share,settings" into sButtons
         break
      default
         put "home,journal,share,settings" into sButtons
         hide btn "save" of me
         send "resizeControl" to me
   end switch
   
end preOpenControl

on mouseup
   local tTarget, tShareControl, tControl, tCard
   local tBrowserExists, tBrowser, tBrowserRect
   local tCdHeight, tSharingHeight
   
   lock screen
   put short name of the target into tTarget
   put (there is a widget "body") into tBrowserExists
   
   
   
   switch tTarget
      case "home"
         if tBrowserExists then
            terminateBrowser
         end if
         put the short name of this card into tCard
         if tCard is "surprise_verse" then
            go to card "surprise_verses"
         else if tCard is among the items of "surprise,surprise_verses,surprise_audio,surprise_darshan,surprise_art" then
            go to card "surprise_menu"
         else if tCard is "main-calendar" and \
               the vis of grp "city-picker-view" then
            unlock screen
            lock screen for visual effect
            hide grp "city-picker-view"
            show grp "main-calendar-view"
            show grp "headerGrp"
            unlock screen with visual effect "dissolve" very fast
         else
            portal_GoStack ("Siva-Siva-Portal")
         end if
         break
         
      case "journal"
         unlock screen
         set the hilited of control tTarget to true
         move control target relative 0,-100 in 100 milliseconds
         move control target relative 0,100 in 70 milliseconds
         send "unHiliteBtn tTarget" to me in 1 seconds
         AddJournalEntry
         dialog_CustomMsg "Saved to Journal"
         break
         
      case "save"
         unlock screen
        
         move control target relative 0,-100 in 100 milliseconds
         move control target relative 0,100 in 70 milliseconds
        
         AddJournalEntry "pReadQuote"
         break
         
      case "share"
         unlock screen
         lock screen for visual effect
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
         show tControl with visual "dissolve" very fast
         break
         
      case "settings"
         if tBrowserExists then
            terminateBrowser
         end if
         portal_GoStack "settings"
         break
      default
         unlock screen
         pass mouseUp
   end switch
   unlock screen
end mouseup


command unHiliteBtn pTarget
   set the hilited of control pTarget to false
end unHiliteBtn

on updateUI
   set the width of me to CardWidth()
   bottomCenterMe (the long id of me), -safeBottomMargin()
end updateUI

on resizeControl
   local tHSpace, tV, tH, tControl, tRect
   put the width of me / (the number of items in sButtons) into tHSpace
   put item 2 of the loc of button 1 of me into tV
   put the left of me + (tHSpace / 2) into tH
   
   repeat for each item tName in sButtons
      put the long name of btn tName of me into tControl
      set the width of tControl to tHSpace
      set the loc of tControl to (tH, tV)
      add tHSpace to tH
   end repeat
   
   set the height of me to 50 + safeBottomMargin()
   set the bottom of me to CardHeight()
   set the rect of grc "footerBackground" to the rect of me
end resizeControl


on mouseMove pNewMouseH, pNewMouseV
   
end mouseMove
