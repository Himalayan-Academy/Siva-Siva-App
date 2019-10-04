Script "stack_Siva-Siva-App_button_id_7643"

/*
# Name: button "enable network tracer" of card "InitializeApp" of stack "Siva-Siva-App"
# ID: button id 7643 of card id 1002 of stack "Siva-Siva-App"
*/


on mouseup
   if the hilite of me then
      set the cNetworkTracerEnabled of stack "Siva-Siva-App" to true
   else
      set the cNetworkTracerEnabled of stack "Siva-Siva-App" to false
   end if
end mouseup
