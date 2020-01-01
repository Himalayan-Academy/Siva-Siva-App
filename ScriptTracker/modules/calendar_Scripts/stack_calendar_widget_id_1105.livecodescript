Script "stack_calendar_widget_id_1105"

/*
# Name: widget "locationSVG" of group "headerGrp" of card "main-calendar" of stack "calendar"
# ID: widget id 1105 of group id 1103 of card id 1002 of stack "calendar"
# Widget Kind: com.livecode.widget.svgpath
*/


on mouseup
  lock screen for visual effect
  hide grp "main-calendar-view"
  hide grp "headerGrp"
  show grp "city-picker-view"
  hide btn "Submit"
  unlock screen  with visual effect "dissolve" very fast
end mouseup
