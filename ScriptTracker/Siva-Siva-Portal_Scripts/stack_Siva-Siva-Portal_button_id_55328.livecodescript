Script "stack_Siva-Siva-Portal_button_id_55328"

/*
# Name: button "goNext" of card "Home" of stack "Siva-Siva-Portal"
# ID: button id 55328 of card id 8169 of stack "Siva-Siva-Portal"
*/


on mouseup
   hide btn "brandLogo"
   # in case menu are visible:
   dispatch "setGlobalNavVisible" to widget "globalNavTree" with "false"
   dispatch "goNextScene" to grp "homeStory"
end mouseup
