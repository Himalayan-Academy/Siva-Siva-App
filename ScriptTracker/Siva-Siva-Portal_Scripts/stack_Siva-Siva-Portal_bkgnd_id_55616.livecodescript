Script "stack_Siva-Siva-Portal_bkgnd_id_55616"

/*
# Name: bkgnd "footer" of stack "Siva-Siva-Portal"
# ID: bkgnd id 55616 of stack "Siva-Siva-Portal"

# Background on card IDs: 51340, 53122
*/


on mouseup
   local tTarget
   lock screen
   put the short name of the target into tTarget
   switch tTarget
      case "Settings-Gear"
         if the platform is "iPhone" then
            # handle the shift of the main nav screen when returning
            set the destroyStack of this stack to false
         end if
         portal_GoStack "settings"
         break
      case "goToMainNav" 
         go to card "mainNav"
         break
      case "goHome"
         go to card "home"
         break
   end switch
   unlock screen
end mouseup

