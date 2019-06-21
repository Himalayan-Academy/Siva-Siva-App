Script "stack_settings_card_id_1261"

/*
# Name: card "disk_data_overview" of stack "settings"
# ID: card id 1261 of stack "settings"
# Behavior: stack "behavior_MediaManager"
*/


on deleteFile
   if  the dialogData ="Yes" then
      deleteFileOnDisk
   end if 
end deleteFile


