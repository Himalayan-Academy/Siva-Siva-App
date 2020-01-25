Script "stack_color-meditation_button_id_1196"

/*
# Name: button "back-arrow" of bkgnd "contentCardHeader" of stack "color-meditation"
# ID: button id 1196 of bkgnd id 1009 of stack "color-meditation"
*/


on mouseUp
   local tWhereAmI
   
   put getCurrentLevel() into tWhereAmI
   switch tWhereAmI
      
      case "colorOpening"
         stopSound
         hideTools
         lock screen
         portal_GoStack  "Siva-Siva-Portal"
         unlock screen
         break
      case "LevelsIndex" 
         go to cd 1
         showTools
         stopSound
         setCurrentLevel ("colorOpening")
         break
      default
         go to card "levelsIndex"
         
   end switch
end mouseUp
