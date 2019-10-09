Script "stack_calendar_button_id_1013"

/*
# Name: button "Submit" of group "city-picker-view" of card "main-calendar" of stack "calendar"
# ID: button id 1013 of group id 1014 of card id 1002 of stack "calendar"
*/


on mouseup
   put the long id of fld  "downloading" into tDownloadNotice
   if not connectivity_PingServer() then
      dialog_CustomMsg "Data is unavailable. Please enable network/internet connection."
      exit to top
   else
      if fld "cityName" = "" then
         doAnswer "Choose a city","OK"
         exit to top
      end if
      put fld "cityName" into tCityName
      bottomCenterMe tDownloadNotice,200
      hide me
      show tDownloadNotice
      setPref "preferences/modules/calendar/city",tCityName
      put calcYearRange() into tYearRange
      put pathToCalendarICS(tYearRange,tCityName,"bin") into tICSPath
      if there is a file tICSPath then delete file tICSPath -- user wants to reload, or chose a new location
      parseUserICSfile tCityName,tYearRange 
      hide tDownloadNotice
      lock screen for visual effect
      show me
      hide grp "city-picker-view" of this cd
      show grp "main-calendar-view" of this cd
      show grp "headerGrp" of this cd
      put tCityName into fld "cityDisplay"
      unlock screen with visual effect dissolve very fast
      
      insertDayInfo the date
   end if
end mouseup
