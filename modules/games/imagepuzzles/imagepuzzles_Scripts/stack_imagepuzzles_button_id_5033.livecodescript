Script "stack_imagepuzzles_button_id_5033"

/*
# Name: button "tileScript" of group "tabControl" of card "utilitesImagePuzzles" of stack "imagepuzzles"
# ID: button id 5033 of group id 5023 of card id 5028 of stack "imagepuzzles"
*/


local tMyHome, tIsHome

On MouseDown
   set the showborder of me to true   
   set the borderWidth of me to 2
   set the layer of me to top
   grab me
end MouseDown

on mouseUp
   set the showBorder of me to false
   put checkHomeProximity() into tIsHome
   if word 1 of tIsHome = true then
      set the loc of me to the uTileLocation of me 
      set the showborder of me to false
   end if
   checkCompletion
end mouseUp

function checkHomeProximity # Cause tile to snap to location if close
   local tLeftDistance,  tTopDistance
   
   put the uTileLocation of me into tMyHome
   put the abs of  (item 1 of the loc of me - item 1 of tMyHome) into tLeftDistance
   put the abs of  (item 2 of the loc of me - item 2 of tMyHome) into tTopDistance
   
   if (the abs of  (item 1 of the loc of me - item 1 of tMyHome)  < 20) AND \
         (the abs of  (item 2 of the loc of me - item 2 of tMyHome) <20) then
      return "true" 
   else
      return false 
   end if 
   
end checkHomeProximity


on dragMove
   
end dragMove
