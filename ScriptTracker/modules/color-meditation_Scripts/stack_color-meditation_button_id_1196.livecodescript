Script "stack_color-meditation_button_id_1196"

/*
# Name: button "back-arrow" of bkgnd "contentCardHeader" of stack "color-meditation"
# ID: button id 1196 of bkgnd id 1009 of stack "color-meditation"
*/


on mouseUp
   put getCurrentLevel() into tWhereAmI
   switch tWhereAmI
      
      case "colorOpening"
         stopSound
         hideTools
         revealBottomNavBar "true"
         break
      case "LevelsIndex" 
         go to cd 1
         hideTools
         stopSound
         setCurrentLevel ("colorOpening")
         revealBottomNavBar "true"
         break
      default
         go to card "levelsIndex"
         
   end switch
   
end mouseUp
