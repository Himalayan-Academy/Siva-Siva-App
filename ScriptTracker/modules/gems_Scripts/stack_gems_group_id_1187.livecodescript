Script "stack_gems_group_id_1187"

/*
# Name: group "goNextQuote" of bkgnd "quoteControl" of stack "gems"
# ID: group id 1187 of bkgnd id 1146 of stack "gems"
*/


on mouseUp
   lock screen
   toggleReadContext ("false") # in case the browser in showing
   fetchImage
   fetchQuote
   unlock screen
end mouseUp
