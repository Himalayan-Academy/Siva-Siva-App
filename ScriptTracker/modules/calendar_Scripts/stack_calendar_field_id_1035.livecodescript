Script "stack_calendar_field_id_1035"

/*
# Name: field "CitySearch" of group "citySearchGrp" of group "city-picker-view" of card "main-calendar" of stack "calendar"
# ID: field id 1035 of group id 1033 of group id 1014 of card id 1002 of stack "calendar"
# Behavior: button id 1031 of stack "calendar"
*/


on textChanged
  lock screen
   if textFldEmpty() then
      put "" into me
   end if
   get the cCityList of fld "citylist"
   filter it with (me & "*")
   put it & cr into fld "citylist"
   unlock screen
   createScroller "citylist" -- reset
end textChanged
