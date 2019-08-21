Script "stack_Siva-Siva-Portal_card_id_8168"

/*
# Name: card "loader" of stack "Siva-Siva-Portal"
# ID: card id 8168 of stack "Siva-Siva-Portal"
*/


-- BM:  Stack script handles redirecting to the correct card
--      This avoids the time necessary to set up the home card
--      if that is not the final destination.

on openCard
   set the loc of btn "brandLogo" to the loc of this card
end openCard

on resizeStack
   set the loc of btn "brandLogo" to the loc of this card
end resizeStack
