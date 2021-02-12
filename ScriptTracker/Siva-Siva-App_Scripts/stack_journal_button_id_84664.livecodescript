Script "stack_journal_button_id_84664"

/*
# Name: button "favorites" of card "edit entries" of stack "journal" of stack "Siva-Siva-App"
# ID: button id 84664 of card id 84667 of stack "journal" of stack "Siva-Siva-App"
*/



on mouseup
   if the cFlag of me then
      set the cFlag of me to false
      refreshUI
      set the backColor of button "favorites" to "green4"
      set the foreColor of button "favorites" to 255,255,255
      set the label of me to "Filter by Favorites"
      
   else
      set the cFlag of me to true
      refreshUI
      set the backColor of button "favorites" to 128,128,255
      set the foreColor of button "favorites" to 255,255,255
      set the label of me to "Show All"
      
   end if
   
end mouseup
