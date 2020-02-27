Script "stack_aagDBLib_button_id_1007"

/*
# Name: button "Start using this stack" of card id 1002 of stack "aagDBLib"
# ID: button id 1007 of card id 1002 of stack "aagDBLib"
*/


on mouseUp
   if the hilite of me then
      start using this stack
   else
      stop using this stack
   end if
end mouseUp
