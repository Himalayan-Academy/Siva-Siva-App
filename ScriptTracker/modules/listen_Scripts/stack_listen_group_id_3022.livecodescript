Script "stack_listen_group_id_3022"

/*
# Name: group "answerDlgGrp" of card "listen-search" of stack "listen"
# ID: group id 3022 of card id 2052 of stack "listen"
*/



/*
Note that Android usually disables and dims the screen while a dialog is up. There is 
a graphic named "cover" on the "Show a dialog" stack that handles this, which you
should copy to the card. The dialog group should be layered above all other visible controls
and the cover graphic should be one layer below the dialog group.

Note that the order of the button names is reversed from the LC convention.
*/

on mouseUp
  if "button" is not in the name of the target then exit mouseUp
  set the dialogData to the label of the target
  hide me 
  if there is a grc "cover" then hide grc "cover"
  doAnswerResponse -- handler in cd script, must check dialog data to see which btn was tapped
end mouseUp


