Script "stack_gems_image_id_1168"

/*
# Name: image "gems-image" of card "images-quotes" of stack "gems"
# ID: image id 1168 of card id 1002 of stack "gems"
*/


local sImageLoc --jg: script local var handles this now

on mousedown
   insertImageDimensions me
  put the loc of me into sImageLoc
  grab me
end mousedown

on mouseup
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
      # if user moved it too far, we reset the location
      --jg: adjust to account for all sides:
      put the width of this cd into tRt
      put the height of this cd into tHt
      
      if (the left of me > 0 or the right of me < tRt) \
            or (the top of me > 0 or the bottom of me < tHt) then
         set the loc of img me to the loc of this cd --jg: only snap to center
      end if
      
      put tCurrentLoc into sImageLoc
   end if
end mouseup
