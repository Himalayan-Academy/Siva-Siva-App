Script "stack_aagDBLib_card_id_1002"

/*
# Name: card id 1002 of stack "aagDBLib"
# ID: card id 1002 of stack "aagDBLib"
*/


on preOpenCard
   if the short name of this stack is among the lines of the stacksinuse then
      set the hilite of btn "Start using this stack" to true
   else
      set the hilite of btn "Start using this stack" to false
   end if
   

   
end preOpenCard
