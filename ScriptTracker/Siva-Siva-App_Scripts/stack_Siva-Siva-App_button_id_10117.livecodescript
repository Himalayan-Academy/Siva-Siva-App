Script "stack_Siva-Siva-App_button_id_10117"

/*
# Name: button "Enable Logging" of card "InitializeApp" of stack "Siva-Siva-App"
# ID: button id 10117 of card id 1002 of stack "Siva-Siva-App"
*/


on mouseup
   if the hilite of me then
      set the uBuildMode of  stack "Siva-Siva-App" to "log"
      set  the logMessage to "log"
      save this stack
   else
      set the uBuildMode of stack "Siva-Siva-App" to "release"
      set  the logMessage to ""
      save this stack
   end if
end mouseup
