Script "stack_color-meditation_card_id_1019"

/*
# Name: card "colorOpening" of stack "color-meditation"
# ID: card id 1019 of stack "color-meditation"
*/


on preopencard
   showTools
   show fld "moduleTitle"
   put "255,0,255" into pColor2
   send "setfillGradient ,,,pColor2,,," to grc colorMeditationBkgnd
end preopencard

on opencard
   send  colorizeControlChars && "moduleTitle" to this stack in 200 milliseconds
   pass opencard
end opencard
   
getProp iAmVisible
   show fld "moduleTitle"
end iAmVisible


