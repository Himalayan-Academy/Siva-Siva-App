Script "stack_Siva-Siva-Portal_button_id_57744"

/*
# Name: button "openGlobalNavTree" of bkgnd "bkgndControls" of stack "Siva-Siva-Portal"
# ID: button id 57744 of bkgnd id 67444 of stack "Siva-Siva-Portal"
*/


on mouseup
   --breakpoint
   dispatch "setGlobalNavVisible" to widget "globalNavTree" with not (the vis of grp "globalNavigation")
end mouseup


