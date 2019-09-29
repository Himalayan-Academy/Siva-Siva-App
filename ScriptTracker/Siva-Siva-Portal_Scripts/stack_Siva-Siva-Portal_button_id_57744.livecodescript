Script "stack_Siva-Siva-Portal_button_id_57744"

/*
# Name: button "openGlobalNav" of card "Home" of stack "Siva-Siva-Portal"
# ID: button id 57744 of card id 8169 of stack "Siva-Siva-Portal"
*/


on mouseup
   --breakpoint
   dispatch "setGlobalNavVisible" to widget "globalNavTree" with not (the vis of grp "globalNav")
end mouseup


