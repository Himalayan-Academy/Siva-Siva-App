Script "stack_color-meditation_graphic_id_1058"

/*
# Name: graphic "Start" of bkgnd "colorMedsToolbar" of stack "color-meditation"
# ID: graphic id 1058 of bkgnd id 1035 of stack "color-meditation"
*/


on mouseup
   
   hide group "aboutDisplay"
   try
      visProgressMessage false
   end try
   put getCurrentLevel() into tCurrentLevel 
   
   switch tCurrentLevel
      case "colorOpening"
         go to card "levelsIndex"
         showLevelsIndex
         break
      case "levelsIndex"
         go to card "runColors"
         break
      case "1"
         go to card "runColors"
         runLevel "1"
         break
      case "2"
         go to card "runColors"
         runLevel "2"
         break
      case "3"
         go to card "runColors"
         runLevel "3"
         break
      case "4"
         go to card "runColors"`
         runLevel "4"
         break
   end switch
   
end mouseup
