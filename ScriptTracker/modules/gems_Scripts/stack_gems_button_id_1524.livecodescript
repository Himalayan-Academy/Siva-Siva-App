Script "stack_gems_button_id_1524"

/*
# Name: button "goNextRealm" of card "images-quotes" of stack "gems"
# ID: button id 1524 of card id 1002 of stack "gems"
*/


on mouseUp
   lock screen
   incrementRealm
   fetchImage
   fetchQuote
   unlock screen
end mouseUp
