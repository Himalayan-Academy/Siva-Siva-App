Script "stack_wordpuzzles_button_id_11502"

/*
# Name: button "back-arrow" of card "word-puzzle" of stack "wordpuzzles"
# ID: button id 11502 of card id 1028 of stack "wordpuzzles"
*/


on mouseUp
   if the platform is "iphone" then
      clearBoard
      hide grp "puzzleControls"
   end if
   go card "blank"
   portal_GoStack ("Siva-Siva-Portal")
end mouseUp
