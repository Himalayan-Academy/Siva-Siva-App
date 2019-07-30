Script "stack_settings_group_id_1378"

/*
# Name: group "resizeFont" of card "info" of stack "settings"
# ID: group id 1378 of card id 1363 of stack "settings"
*/


on mouseup
   if the textSize of fld "info-text" = 28 then
      set the textSize of fld "info-text" to 18
   else
      set the textsize of fld "info-text" to (the textsize of fld "info-text" + 2)
   end if
end mouseup
