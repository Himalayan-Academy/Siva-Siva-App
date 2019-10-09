Script "stack_listen_card_id_2052"

/*
# Name: card "listen-search" of stack "listen"
# ID: card id 2052 of stack "listen"
# Behavior: stack "behavior_ListenUI"
*/


on opencard
   set the acceleratedRendering of this stack to false
   audioIsRunning
end opencard

on closeCard
   set the acceleratedRendering of this stack to true
end closeCard

