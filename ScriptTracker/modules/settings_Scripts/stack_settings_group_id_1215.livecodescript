Script "stack_settings_group_id_1215"

/*
# Name: group "settings-options-1" of card "settings-home" of stack "settings"
# ID: group id 1215 of card id 1002 of stack "settings"
*/


on mouseup 
   put the short name of the target  into tMouseEvent
   switch tMouseEvent
      case "App News"
         go to card "info"
         displayInfo 1,"App News"
         news_NoNews # see lib_SivaSiva, Getter/Setter sets it "false"
         break
      case "About"
         go to card "info"
         displayInfo 1,"About"
         break
      case "Release Notes"
         go to card "info"
         displayInfo 1,"release-notes"
         break
      case "Feedback"
         sendFeedBack
         break
      case "Credits"
         go to card "info"
         displayInfo 1,"Credits"
         break
      case "My Data"
         go to cd "disk_data_overview"
         break
      case "User Guide"
         # send people to a video tutorial
         break
      case "Close App"
         doAnswer "Download this audio file?", "Download,Cancel","downloadAffirmed"
         doAnswer "Closing SivaSiva. Goodbye!","OK,Cancel","quitApp"
         break
   end switch
   put "read/" & tMouseEvent into tAction
   tracking_RecordActivity "Settings", tAction
end mouseup
