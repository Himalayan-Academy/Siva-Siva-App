Script "stack_color-meditation_card_id_1019"

/*
# Name: card "colorOpening" of stack "color-meditation"
# ID: card id 1019 of stack "color-meditation"
*/


on preopencard
   showTools
   show fld "moduleTitle"
   put sivasiva_AssetFolder() & "audio/angelic-ambience_lo-res.mp3" into pSoundFile
   playSound pSoundFile
   send  colorizeControlChars && "moduleTitle" to this stack in 2 seconds
   put "255,0,255" into pColor2
   send "setfillGradient ,,,pColor2,,," to grc colorMeditationBkgnd
end preopencard

on opencard
   blinkStart "true"
   pass opencard
end opencard
   
getProp iAmVisible
   show fld "moduleTitle"
end iAmVisible
