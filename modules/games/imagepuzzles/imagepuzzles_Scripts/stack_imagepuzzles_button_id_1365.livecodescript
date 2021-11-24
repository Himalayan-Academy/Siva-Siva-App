Script "stack_imagepuzzles_button_id_1365"

/*
# Name: button "tileScript" of card "mainImagePuzzle" of stack "imagepuzzles"
# ID: button id 1365 of card id 1002 of stack "imagepuzzles"
*/


local tMyHome, tIsHome, tNoGrab

On MouseDown
   put checkHomeProximity() into tNoGrab 
   set the layer of me to top
   if tNoGrab is false then
      set the outerglow of me to setTileGlow()
      grab me
   end if
   
   
end MouseDown


on mouseUp
   put checkHomeProximity() into tIsHome
   if word 1 of tIsHome = true then
      set the loc of me to the uTileLocation of me 
      set the showborder of me to false
      set the layer of me to 10 
   end if
   set the outerglow of me to empty
   checkCompletion
   
   if the left of me < 1 then
      set the left of me to 0
   end if
   
   if the right  of me > 414 then
      set the right of me to 414
   end if
   if the bottom of me  > 700 then  
      set the bottom of me to 700
   end if
   
   if the top of me < 1 then
      set the top of me to 0
   end if
   
end mouseUp

function checkHomeProximity # Cause tile to snap to location if close
   local tLeftDistance,  tTopDistance
   
   put the uTileLocation of me into tMyHome
   put the abs of  (item 1 of the loc of me - item 1 of tMyHome) into tLeftDistance
   put the abs of  (item 2 of the loc of me - item 2 of tMyHome) into tTopDistance
   
   if (the abs of  (item 1 of the loc of me - item 1 of tMyHome)  < 20) AND \
         (the abs of  (item 2 of the loc of me - item 2 of tMyHome) <20) then
      put "true" into tNoGrab
      return "true" 
   else
      put "false" into tNoGrab
      return false 
   end if 
   set the layer of grp "makeTiles" to top
   set the layer of btn "backArrow" to top
end checkHomeProximity
