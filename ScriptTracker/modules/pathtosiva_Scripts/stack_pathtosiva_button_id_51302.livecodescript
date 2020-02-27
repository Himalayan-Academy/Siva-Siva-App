Script "stack_pathtosiva_button_id_51302"

/*
# Name: button "SVG Back" of bkgnd "headerGrp" of stack "pathtosiva"
# ID: button id 51302 of bkgnd id 1078 of stack "pathtosiva"
*/


on mouseUp
   if tocVisible() then 
      toggleMenu
      exit to top
   end if 
   
   
   if the short name of this cd <> "Photo Index" then
      goCd "Photo Index","push right"
   else -- photo index cd
      
      # NOTE: for now we take the user home
      # in the future with will go back to "Choose Your Path"
      
      portal_GoStack "Siva-Siva-Portal"
      
      # goCd "choose your path","reveal right"
      
   end if
end mouseUp
--put getPref("index") into tIndexCd

--   if the short name of this cd <> tIndexCd then
--      goCd tIndexCd,"push right"
--   else -- index cd
