Script "stack_settings_card_id_1363"

/*
# Name: card "info" of stack "settings"
# ID: card id 1363 of stack "settings"
*/


on opencard
   set the acceleratedRendering of this stack to true
   audioIsRunning
end opencard
on closecard
   set the acceleratedRendering of this stack to false
end closecard
