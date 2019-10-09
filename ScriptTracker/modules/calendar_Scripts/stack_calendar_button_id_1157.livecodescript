Script "stack_calendar_button_id_1157"

/*
# Name: button "testing" of card "main-calendar" of stack "calendar"
# ID: button id 1157 of card id 1002 of stack "calendar"
*/


on mouseup
   
   answer "Show or Clear Local Vars" with "Show" or "Clear"
   if it is "Show" then 
      showLocals
   else
      clearLocals
   end if
   
end mouseup
