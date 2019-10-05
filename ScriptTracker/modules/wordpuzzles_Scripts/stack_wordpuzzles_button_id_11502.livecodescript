Script "stack_wordpuzzles_button_id_11502"

/*
# Name: button "back-arrow" of card "word-puzzle" of stack "wordpuzzles"
# ID: button id 11502 of card id 1028 of stack "wordpuzzles"
*/


on mouseUp
   show grc "blankScreen"
   clearBoard
   if the platform is "iphone" then
      wait 50 milliseconds with messages
   end if
   portal_GoStack ("Siva-Siva-Portal")
end mouseUp
