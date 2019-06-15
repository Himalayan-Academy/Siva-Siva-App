Script "stack_surprise_button_id_1270"

/*
# Name: button "Random Image Behavior" of card "image-resources" of stack "surprise"
# ID: button id 1270 of card id 1023 of stack "surprise"
*/


local sImageLoc,sViewState --jg: script local var handles this now

on mousedown
   insertImageDimensions (the long id of me)
  put the loc of me into sImageLoc
  grab me
end mousedown

on mouseup
   if sViewState is empty then put 1 into sViewState
   put the loc of me  into tCurrentLoc
   # On mobile the image if very sensitive and moves
   # we need to establish a delta that is acceptable a
   # if within that delta.. then get the next quote
   put (item 1 of sImageLoc) - (item 1 of tCurrentLoc) into tHShift
   put (item 2 of sImageLoc) - (item 2 of tCurrentLoc) into tVShift --jg: account for both horiz & vert shifts
   put abs(tHShift)  < 20 and abs(tVShift)  < 20 into tIsTap --jg: no significant movement either direction
   
   if tIsTap then --jg: tapping now toggles img size      
      switchViewState        
   else
      --       # if user moved it too far, we reset the location
      --       --jg: adjust to account for all sides:
      --       put the width of this cd into tRt
      --       put the height of this cd into tHt
      
      --       if (the left of me > 0 or the right of me < tRt) \
         --             or (the top of me > 0 or the bottom of me < tHt) then
      --          set the loc of me to the loc of this cd --jg: only snap to center
      --       end if
      
      put tCurrentLoc into sImageLoc
   end if
end mouseup
 
command switchViewState 
   switch sViewState          
      case 1  
            toggleImgSize (me),,(the width of this card -10) 
         put 2 into sViewState      
         break
      case  2 #  image is full size, shrink to card
         toggleImgSize (me),,(the formattedwidth of me) 
         put 1 into sViewState     
   end switch
end switchViewState
