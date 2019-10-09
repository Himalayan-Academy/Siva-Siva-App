Script "stack_calendar_bkgnd_id_1004"

/*
# Name: bkgnd "footerNavigation" of stack "calendar"
# ID: bkgnd id 1004 of stack "calendar"

# Background on card IDs: 1002
*/


global sConfigA

on mouseUp
   put the short name of the target into tTarget
   switch tTarget
      case "go-home-portal"
         if the vis of grp "city-picker-view" then
            lock screen for visual effect
            hide grp "city-picker-view"
            show grp "main-calendar-view"
            show grp "headerGrp"
            unlock screen  with visual effect dissolve very fast
         else
            portal_GoStack ("Siva-Siva-Portal")
         end if
         
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
