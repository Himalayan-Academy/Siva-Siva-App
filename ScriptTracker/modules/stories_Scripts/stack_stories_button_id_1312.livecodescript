Script "stack_stories_button_id_1312"

/*
# Name: button "goNext" of group "homeStoryBkgnd" of card "storiesHome" of stack "stories"
# ID: button id 1312 of group id 1308 of card id 1002 of stack "stories"
*/


on mouseup
   if fld "homeStoryText" contains "User Guide" then
      showStoryMenu
   else
      goNextScene
   end if
end mouseup
