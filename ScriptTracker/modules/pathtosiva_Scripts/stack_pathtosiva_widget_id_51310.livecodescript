Script "stack_pathtosiva_widget_id_51310"

/*
# Name: widget "expander" of group "bodytextGrp" of card "lessonView" of stack "pathtosiva"
# ID: widget id 51310 of group id 1093 of card id 1083 of stack "pathtosiva"
# Widget Kind: com.livecode.widget.svgpath
*/


on mouseup
   if ( ( the bottom of fld "caption" ) -  (the bottom of img "heroImg") ) <  50 then -- expanded
      slideCaption true 
   end if
end mouseup
