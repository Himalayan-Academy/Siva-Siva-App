Script "stack_calendar_card_id_1002"

/*
# Name: card "main-calendar" of stack "calendar"
# ID: card id 1002 of stack "calendar"
# Behavior: stack "behavior_Calendar"
*/



on preOpenCard
   if isMobile() then
      set the fullscreenMode of this stack to "showAll"
      mobileSetAllowedOrientations "portrait,portrait upside down"
   end if
end preOpenCard

on opencard
   
   put calcYearRange() into tYearRange
   put getPref("preferences/modules/calendar/city") into tCityName -- empty if new launch
   put (there is a file pathToCalendarICS(tYearRange,tCityName,"bin")) into tICSExists
   set the vis of grp "main-calendar-view" of me to tICSExists
   set the vis of grp "city-picker-view" of me to not tICSExists
   set the vis of fld "cityName" of grp "city-picker-view" of me to tICSExists
   if tICSExists then
      show grp "main-calendar-view"
      show grp "headerGrp"
      put tCityName into fld "cityDisplay" of grp "headerGrp" of me
      parseUserICSfile tCityName,tYearRange -- load existing calendar
      insertDayInfo the date
   else -- init
      hide grp "main-calendar-view"
      hide grp "headerGrp"
      hide btn "Submit" of grp "city-picker-view" of me
      put "" into fld "cityName" of grp "city-picker-view" of me
      put tCityName into fld "cityDisplay" of grp "headerGrp" of me
   end if
   pass opencard
end opencard

on closeCard
   put "main-calendar" into pDataA["card"]
   put  "Hindu Calendar - " & fld "CityDisplay" into pTitle
   Journal_RecordEntry "calendar",pTitle,pDataA
end closeCard

on mouseUp -- mobile: dismiss grp
  if the vis of grp "citySearchGrp" then send "showCityList false" to grp "citySearchGrp"
end mouseUp

on keyboardDeactivated -- if user dismisses keyboard during search, this allows them to bring it back by tapping the fld
  focus on nothing
end keyboardDeactivated
