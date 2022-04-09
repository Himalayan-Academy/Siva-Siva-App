Script "stack_pathtosiva_group_id_51328"

/*
# Name: group "expander" of group "bodytextGrp" of card "lessonView" of stack "pathtosiva"
# ID: group id 51328 of group id 1093 of card id 1083 of stack "pathtosiva"
*/


on mouseup
   
   if ( ( the bottom of fld "caption" ) -  (the bottom of img "heroImg") ) <  50 then -- expanded
      slideCaption true 
   else
      slideCaption false 
   end if
end mouseup
