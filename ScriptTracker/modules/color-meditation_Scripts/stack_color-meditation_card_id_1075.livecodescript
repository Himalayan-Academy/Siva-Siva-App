Script "stack_color-meditation_card_id_1075"

/*
# Name: card "levelsIndex" of stack "color-meditation"
# ID: card id 1075 of stack "color-meditation"
*/


on preopencard  
   hide grc "start"
   showLevelsIndex
   hide fld "moduleTitle"   
   put "Levels Index" into fld "title" 
   setBackGroundGradient "0,200,0" --"255,6,23"
   setCurrentLevel "LevelsIndex"
   hide grc "start"
   pass preOpenCard
end preopencard

getProp iAmVisible  # just playing with virtual properties... trying to see how to use these things
   showLevelsIndex
end iAmVisible

on showLevelsIndex  # not happening.. maybe later
   -- BM: adding variable declarations just for strict compilation
   local sLastLevel, sConfigColor
   show grp "levelsLinks"
   put  sConfigColor["color-meditation"]["progress"]["level"] into sLastLevel
   repeat with x = 1 to sLastLevel 
      show group ("level" & x)
   end repeat
end showLevelsIndex

command selectionHilites
   -- put the target
   resetHiLites
   set the outerglow["color"] of the target to "200,200,200"
end selectionHilites

command resetHiLites
   repeat with x = 1 to 4
      set the outerglow["color"] of button ("level"&x&"Link") to "255,238,196"
   end repeat
end resetHiLites

on closeCard
   show grc "Start"
end closeCard
# beige 255,238,196
