Script "stack_surprise_bkgnd_id_1276"

/*
# Name: bkgnd "footerNavigation" of stack "surprise"
# ID: bkgnd id 1276 of stack "surprise"

# Background on card IDs: 1494, 1002, 1106, 1031, 1421, 1039, 1037
*/


global sConfigA

on mouseup 
   put short name of the target into pTarget
   switch pTarget
      case "go-Home-Portal"
         
         if the short name of this card ="surprise_verse" then
            go to card "surprise_verses"
         else
            portal_GoStack ("Siva-Siva-Portal") --card "Surprise" of stack
         end if
         break
      case "add-favorites"
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
         put the long id of group "share-ui" of this card into pControl
         bottomCenterMe pControl
         
         deleteMobileControl  "audioPlayer"
         show group "share-ui" with visual dissolve very fast
         unlock screen
         break
      case "settings-gear"
         portal_GoStack "settings"
         break
   end switch   
end mouseup
