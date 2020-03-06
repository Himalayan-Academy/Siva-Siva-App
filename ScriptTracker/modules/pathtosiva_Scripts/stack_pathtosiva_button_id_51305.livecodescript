Script "stack_pathtosiva_button_id_51305"

/*
# Name: button "expander" of group "bodytextGrp" of card "lessonView" of stack "pathtosiva"
# ID: button id 51305 of group id 1093 of card id 1083 of stack "pathtosiva"
*/


on mouseup
   if ( ( the bottom of fld "caption" ) -  (the bottom of img "heroImg") ) <  50 then -- expanded
      slideCaption true 
   end if
end mouseup


-- reset the loc to work around LC bug where formattedHeight is not updated
--   else
--      put the mouseloc into sMouseLoc
--      put sMouseLoc into sStartLoc
--      put the milliseconds into sStartMS
--      checkGlossary the mouseChunk -- for glossary flags per word on touch
