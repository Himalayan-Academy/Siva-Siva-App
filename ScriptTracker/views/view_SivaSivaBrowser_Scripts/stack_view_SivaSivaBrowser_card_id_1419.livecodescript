Script "stack_view_SivaSivaBrowser_card_id_1419"

/*
# Name: card "Loader" of stack "view_SivaSivaBrowser"
# ID: card id 1419 of stack "view_SivaSivaBrowser"
*/


on openCard
   ntinfo ("from loader: " & (the lockscreen))
   wait 80 milliseconds with messages
   go next card
end openCard

