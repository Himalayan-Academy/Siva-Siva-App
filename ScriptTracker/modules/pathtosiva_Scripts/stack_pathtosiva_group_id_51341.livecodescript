Script "stack_pathtosiva_group_id_51341"

/*
# Name: group "answerDlgGrp" of card "about" of stack "pathtosiva"
# ID: group id 51341 of card id 1246 of stack "pathtosiva"
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


/*
Typically these handlers would go in a stack script, backscript, or behavior.
Call like this:

-- doAnswer "This is a message.","Continue,Cancel" -- rightmost btn name FIRST

Use a handler like this in the card script:

command doAnswer pMsg,pBtns
  -- pMsg = prompt
  -- pBtns = comma-delimited names of up to 2 btns to show;
  if there is no grp "answerDlgGrp" then
    exit doAnswer
  end if
  set the dialogData to empty -- init
  put pMsg into fld "lbl-dialogPrompt" of grp "answerDlgGrp"
  set the label of btn "dialogAffirm" of grp "answerDlgGrp" to toUpper(item 1 of pBtns)
  get item 2 of pBtns
  set the vis of btn "dialogCancel" of grp "answerDlgGrp" to (it <> "")
  set the label of btn "dialogCancel" of grp "answerDlgGrp" to toUpper(it)
  if there is a grc "cover" then show grc "cover"
  show grp "answerDlgGrp" -- cd must have a "doAnswerResponse" handler to read dialogData and respond
end doAnswer


To manage the response, use a "doAnswerResponse" handler like this in the card or stack script:

command doAnswerResponse -- sent from doAnswer dlg
  get the dialogData
  if it contains "cancel" then
    exit to top
  else
    -- execute an action here
  end if
end doAnswerResponse

*/
