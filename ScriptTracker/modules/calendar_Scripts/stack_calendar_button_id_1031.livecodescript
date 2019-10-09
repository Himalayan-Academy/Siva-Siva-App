Script "stack_calendar_button_id_1031"

/*
# Name: button "hintTextFieldBehavior" of card "main-calendar" of stack "calendar"
# ID: button id 1031 of card id 1002 of stack "calendar"
*/



constant kDisabledColor = "138,138,138" -- text, if bg is white

function textFldEmpty
  get the text of me
  if it = "" or it = the cDefaultPrompt of me then
    return true
  end if
  return false
end textFldEmpty

on openField
  if textFldEmpty() then
    put "" into me
    if the backcolor of me = "255,255,255" or the backcolor of me = "" then
      set the textcolor of me to empty
    else
      set the textcolor of me to "255,255,255" -- color bg
    end if 
  end if 
end openField

on closeField
  resetDefaultText
end closeField

on exitField
  resetDefaultText
end exitField

on resetDefaultText
   if textFldEmpty() then
      put the cDefaultPrompt of me into me
      if the backcolor of me = "255,255,255" or the backcolor of me = "" then
         set the textcolor of me to kDisabledColor
      else
         set the textcolor of me to "255,255,255" -- color bg
      end if 
   end if
end resetDefaultText
