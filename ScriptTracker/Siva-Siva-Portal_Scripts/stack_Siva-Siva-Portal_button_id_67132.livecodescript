Script "stack_Siva-Siva-Portal_button_id_67132"

/*
# Name: button "Create Tree Array" of card "Home" of stack "Siva-Siva-Portal"
# ID: button id 67132 of card id 8169 of stack "Siva-Siva-Portal"
*/


on mouseup
   answer "Choose Menu" with "MainMenu" or "MyMenu" 
   if it is "mainMenu" then
      dispatch "createNavTree" to widget "globalNavTree" with it
   else
      dispatch "loadFavoritesToMyHome" to widget "globalNavTree" 
   end if
end mouseup


