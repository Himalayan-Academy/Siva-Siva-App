Script "stack_settings_group_id_1215"

/*
# Name: group "settings-options-1" of card "settings-home" of stack "settings"
# ID: group id 1215 of card id 1002 of stack "settings"
*/


on mouseup 
   local tMouseEvent, tAction
   put the short name of the target  into tMouseEvent
   switch tMouseEvent
      case "App News"
         displayInfo 1,"App News"
         go to card "info"
         break
      
      case "About"
         displayInfo 1,"About"
         go to card "info"
         break
         
      case "Release Notes"
         displayInfo 1,"release-notes"
         go to card "info"
         break
         
      case "Feedback"
         sendFeedBack
         break
         
      case "Credits"
         displayInfo 1,"Credits"
         go to card "info"
         break
         
      case "My Data"
         go to cd "disk_data_overview"
         break
         
      case "User Guide"
         displayInfo 1,"User Guide"
         go to card "info"
         break
   end switch

   --send "CreateScroller info-text" to fld "info-text" in 50 milliseconds
   
   put "read/" & tMouseEvent into tAction
   tracking_RecordActivity "Settings", tAction
end mouseup
