Script "stack_settings_card_id_1363"

/*
# Name: card "info" of stack "settings"
# ID: card id 1363 of stack "settings"
*/


on preOpenCard
   send "CreateScroller info-text" to fld "info-text" in 50 milliseconds
   pass preOpenCard
end preOpenCard
