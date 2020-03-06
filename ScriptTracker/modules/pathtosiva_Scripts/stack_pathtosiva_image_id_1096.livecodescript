Script "stack_pathtosiva_image_id_1096"

/*
# Name: image "heroImg" of group "bodytextGrp" of card "lessonView" of stack "pathtosiva"
# ID: image id 1096 of group id 1093 of card id 1083 of stack "pathtosiva"
*/


on mouseup
   if ( ( the bottom of fld "caption" ) -  (the bottom of img "heroImg") ) <  50 then -- expanded
      slideCaption true 
   end if
end mouseup

