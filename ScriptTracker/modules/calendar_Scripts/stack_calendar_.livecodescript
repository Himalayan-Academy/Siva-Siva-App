Script "stack_calendar_"

/*
# Name: stack "calendar"
# ID: stack "calendar"
*/


On preopencard
   set the fullscreenmode of this stack to "showAll"
   if isMobile() then    
      mobileSetAllowedOrientations "portrait,portrait upside down"
      mobileSetFullScreenRectForOrientations "portrait,portrait upside down","0,0,414,726"
   end if
end preopencard

on opencard
   setCardCoords
   audioIsRunning  
end opencard

on cleanUpGui
   put empty into fld "cityDisplay"
   put empty into fld "monthDisplay"
   put empty into fld "allDataForOneDay"
   put empty into fld "current_days"
end cleanUpGui

on journalResume pDataA, pEntryA
   go to card "main-calendar"
end journalResume

on closeStack
   portal_SetLastStack "calendar"
end closeStack
