Script "stack_Siva-Siva-App_button_id_4082"

/*
# Name: button "Tools" of group "Log Test" of card "development" of stack "Siva-Siva-App"
# ID: button id 4082 of group id 4076 of card id 4075 of stack "Siva-Siva-App"
*/


on mouseUp
   if the environment = "development" then
      go to stack "Siva-Siva Tools"
   else
      answer warning "Only available in develoment environment!"
   end if
end mouseUp
