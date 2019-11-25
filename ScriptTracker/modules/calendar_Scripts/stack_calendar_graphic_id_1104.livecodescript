Script "stack_calendar_graphic_id_1104"

/*
# Name: graphic "backdrop" of group "headerGrp" of card "main-calendar" of stack "calendar"
# ID: graphic id 1104 of group id 1103 of card id 1002 of stack "calendar"
*/


constant kIcons = "locationSVG,editSVG,backSVG,forwardSVG"

on mouseUp -- catch taps on transparent icon regions on mobile
   local tMouse
   put the clickloc into tMouse
   repeat for each item i in kIcons
      if tMouse is within the rect of control i then
         send "mouseup" to control i
         exit repeat
      end if
   end repeat
end mouseUp
