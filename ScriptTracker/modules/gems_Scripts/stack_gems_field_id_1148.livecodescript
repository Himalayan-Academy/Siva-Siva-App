Script "stack_gems_field_id_1148"

/*
# Name: field "gems-quote" of bkgnd "quoteControl" of stack "gems"
# ID: field id 1148 of bkgnd id 1146 of stack "gems"
# Behavior: stack "behavior_mobileScroller"
*/


on mouseUp
   if the target is control "gems-quote" then
      send "mouseup" to grp "quoteControl"
   else
      pass mouseup
   end if
end mouseUp
