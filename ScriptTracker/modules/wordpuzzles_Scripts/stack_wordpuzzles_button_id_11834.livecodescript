Script "stack_wordpuzzles_button_id_11834"

/*
# Name: button "back-arrow-test" of card "word-puzzle" of stack "wordpuzzles"
# ID: button id 11834 of card id 1028 of stack "wordpuzzles"
*/


on mouseUp
   if the platform is "iphone" then
      clearBoard
      set the loc of btn "navigationOverlay" to the loc of this card
      show btn "navigationOverlay"
   end if
   portal_GoStack ("Siva-Siva-Portal")
end mouseUp

