Script "stack_color-meditation_graphic_id_1058"

/*
# Name: graphic "Start" of bkgnd "colorMedsToolbar" of stack "color-meditation"
# ID: graphic id 1058 of bkgnd id 1035 of stack "color-meditation"
*/


on mouseup
   if the short name of this card <> "runColors" then
      go to card "LevelsIndex"
   else 
      pass mouseup
   end if
end mouseup
