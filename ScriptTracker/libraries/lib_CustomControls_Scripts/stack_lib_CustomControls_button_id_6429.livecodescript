Script "stack_lib_CustomControls_button_id_6429"

/*
# Name: button "Show Toast/Notification" of card "dialog_CustomMsg" of stack "lib_CustomControls"
# ID: button id 6429 of card id 6424 of stack "lib_CustomControls"
*/


on mouseup
   
   put "This is a message to the user. You have some really marvelous news!" into tMsg
   show btn "DIALOGAFFIRM" 
   -- put "This is a one liner. message to the user. " into tMsg
   # resize dynamically to card width
   # relative to the bottom
   put the width of this card into tCdWidth
   put the height of this card into tCdHeight
   put tMsg into fld "lbl-dialogPrompt"
   put the number of lines of the formattedText of fld "lbl-dialogPrompt" into tmsgLines
  
   if tMsgLines > 1 then
      set the margins of fld "lbl-dialogPrompt" to 24,20,24,24
   else
      set the margins of fld "lbl-dialogPrompt" to 24,14,14,14
   end if
   set the width of fld "lbl-dialogPrompt" to tCdWidth
   set the left of fld "lbl-dialogPrompt" to 0
   set the textcolor fld "lbl-dialogPrompt" to 230,230,230
   # if the button is required just add height
   if the vis of  btn "DIALOGAFFIRM" then
      put 24 into tBtnHeight
   end if 
   
   set the height of fld "lbl-dialogPrompt" to ((the formattedHeight of fld "lbl-dialogPrompt") + tBtnHeight)
   set the bottom of fld "lbl-dialogPrompt"  to tCdHeight
   set the bottomright of btn "DIALOGAFFIRM" to tCdwidth-24,tCdheight-8
   
   
end mouseup
