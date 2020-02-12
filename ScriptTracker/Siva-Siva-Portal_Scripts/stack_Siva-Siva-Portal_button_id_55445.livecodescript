Script "stack_Siva-Siva-Portal_button_id_55445"

/*
# Name: button "brandLogo" of bkgnd "bkgndControls" of stack "Siva-Siva-Portal"
# ID: button id 55445 of bkgnd id 67444 of stack "Siva-Siva-Portal"
*/


on mouseup
   if not isMobile() then
      portal_GoStack "shum"
   else
      ask password "Secret Gateway"
      if it is "10008shum" then
         portal_GoStack "shum"
      end if
   end if
   
end mouseup
