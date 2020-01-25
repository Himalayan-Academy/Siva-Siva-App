Script "stack_color-meditation_card_id_1019"

/*
# Name: card "colorOpening" of stack "color-meditation"
# ID: card id 1019 of stack "color-meditation"
*/


on preopencard
   local tColor
   showTools
   show fld "moduleTitle"
   show grc "Start"
   put "255,0,255" into tColor
   send "setfillGradient ,,,tColor,,," to grc "colorMeditationBkgnd"
   pass preOpenCard
end preopencard

on opencard
   send  "colorizeControlChars" && "moduleTitle" to this stack in 200 milliseconds
   pass opencard
end opencard
   
getProp iAmVisible
   show fld "moduleTitle"
end iAmVisible


