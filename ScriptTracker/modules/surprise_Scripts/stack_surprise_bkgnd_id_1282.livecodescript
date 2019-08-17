Script "stack_surprise_bkgnd_id_1282"

/*
# Name: bkgnd "header" of stack "surprise"
# ID: bkgnd id 1282 of stack "surprise"

# Background on card IDs: 1494, 1002, 1106, 1031, 1421, 1039, 1037
*/


on resizeControl
   local tLoc
   put the loc of me into tLoc
   subtract 5 from item 2 of tLoc
   set the loc of fld "Title" to tLoc
   set the rect of grc "portal-title-bkgnd" to the rect of me
end resizeControl
