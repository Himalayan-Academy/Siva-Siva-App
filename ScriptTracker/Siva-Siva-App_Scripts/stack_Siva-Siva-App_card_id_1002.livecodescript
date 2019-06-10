Script "stack_Siva-Siva-App_card_id_1002"

/*
# Name: card "InitializeApp" of stack "Siva-Siva-App"
# ID: card id 1002 of stack "Siva-Siva-App"
# Behavior: stack "behavior_InitSivaSivaProject"
*/


/*
This is the Siva-Siva-App's project loading card.
The handlers for this card have been moved to the "behavior_InitSivaSivaProject" = this cards behavior.
*/

on mouseup
   if  commandKey() = "down" then
      toplevel "Siva-Siva-Portal"
   end if
end mouseup

on opencard
   if the environment is not "development" then
      hide button "enable network tracer"
   else
      show button "enable network tracer"
      choose browse tool
   end if
   
   pass opencard
end opencard
