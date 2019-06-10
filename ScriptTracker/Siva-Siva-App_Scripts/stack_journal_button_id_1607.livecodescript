Script "stack_journal_button_id_1607"

/*
# Name: button "favorites" of card id 1002 of stack "journal" of stack "Siva-Siva-App"
# ID: button id 1607 of card id 1002 of stack "journal" of stack "Siva-Siva-App"
*/



on mouseup
   if the cFlag of me then
      set the backColor of button "favorites" to "green4"
      set the foreColor of button "favorites" to 255,255,255
      set the cFlag of me to false
   else
      set the backColor of button "favorites" to 128,128,255
      set the foreColor of button "favorites" to 255,255,255
      set the cFlag of me to true
   end if
   refreshUI
end mouseup
