Script "stack_view_BrowserLandscape_card_id_1419"

/*
# Name: card "Loader" of stack "view_BrowserLandscape"
# ID: card id 1419 of stack "view_BrowserLandscape"
*/


on openCard
   ntinfo ("from loader: " & (the lockscreen))
   wait 80 milliseconds with messages
   go next card
end openCard

