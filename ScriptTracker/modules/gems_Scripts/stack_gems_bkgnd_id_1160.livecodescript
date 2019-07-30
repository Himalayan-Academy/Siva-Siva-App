Script "stack_gems_bkgnd_id_1160"

/*
# Name: bkgnd "footerNav" of stack "gems"
# ID: bkgnd id 1160 of stack "gems"

# Background on card IDs: 1002, 1184, 1179
*/


global sConfigA

on mouseup
   local pTarget, tShareControl, pControl
   put short name of the target into pTarget
   switch pTarget
      case "go-Home-Portal"
         portal_GoStack  "Siva-Siva-Portal"
         break
      case "saveToJournal"
         AddJournalEntry "pReadQuote"
         set the hilited of control ptarget to true
         move control target relative 0,-100 in 500 milliseconds
         move control target relative 0,100 in 110 milliseconds
         send "unHiliteBtn ptarget" to me in 1 seconds
         break
         
      case "add-favorites"
         portal_GoStack "Journal"
         break
      case "share"
         lock screen
         put sConfigA["shareControl"] into tShareControl  
         if there is widget "body" then
            set the top of widget "body"  to -50
         end if
         
         if (exists(group "share-ui" of this card) ) then 
            # we had to get it off screen for Android 
            # here we put it a back.
            show group "share-ui" with visual "dissolve" very fast
         else
            
            copy tShareControl to this card 
         end if
         put the long id of group "share-ui" of this card into pControl
         bottomCenterMe pControl
         unlock screen
         break
      case "settings-gear"
         portal_GoStack "settings"
         break
   end switch   
end mouseup

command unHiliteBtn pTarget
   set the hilited of control ptarget to false
end unHiliteBtn

on resizeControl
   local tHSpace, tV, tH, tControl
   put the width of me / 5 into tHSpace
   put item 2 of the loc of me into tV
   put the left of me + (tHSpace / 2) into tH
   repeat with tButton = 1 to 5
      put the long name of btn tButton of me into tControl
      set the width of tControl to tHSpace
      set the loc of tControl to (tH, tV)
      add tHSpace to tH
   end repeat
end resizeControl
