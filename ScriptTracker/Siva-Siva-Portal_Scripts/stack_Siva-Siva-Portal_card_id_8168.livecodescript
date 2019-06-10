Script "stack_Siva-Siva-Portal_card_id_8168"

/*
# Name: card "loader" of stack "Siva-Siva-Portal"
# ID: card id 8168 of stack "Siva-Siva-Portal"
*/


on openCard
--   // if we are opening the stack  from any place other the
--   // SivaSivaApp. that is, another module, we always to go to
--   // to the main navigation.

--   if  (Portal_GetLaunchStack() = "Siva-Siva-App") OR \
--         (Portal_GetLaunchStack() = empty)  then
go card "home"
--   else 
--      go card  "mainNav"
--   end if 

--   if (the lockscreen) then unlock screen

end openCard
