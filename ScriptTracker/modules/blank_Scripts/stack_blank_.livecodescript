Script "stack_blank_"

/*
# Name: stack "blank"
# ID: stack "blank"
*/


on preOpenStack
   if isMobile() then    
      mobileSetAllowedOrientations "portrait,portrait upside down"
   end if
end preOpenStack

on openStack
   wait 50 milliseconds with messages
   --go stack "Siva-Siva-Portal"
   portal_FinishGoStack
   close stack "blank"
end openStack
