Script "stack_daily-lesson_bkgnd_id_1160"

/*
# Name: bkgnd "footerNavigation" of stack "daily-lesson"
# ID: bkgnd id 1160 of stack "daily-lesson"

# Background on card IDs: 1002
*/


global sConfigA

on mouseUp
   put the short name of the target into tTarget
   switch tTarget
      case "go-home-portal"
         resetUI
         portal_GoStack ("Siva-Siva-Portal")
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
         put the long id of group "share-ui" of this card into pControl
         bottomCenterMe pControl
         
         deleteMobileControl  "audioPlayer"
         show group "share-ui" with visual dissolve very fast
         unlock screen
         break
         
      case "add-favorites"
         portal_GoStack "Journal"
         break
   end switch
end mouseup
