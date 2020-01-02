Script "stack_calendar_"

/*
# Name: stack "calendar"
# ID: stack "calendar"
*/


on preopencard
   if isMobile() then    
      mobileSetAllowedOrientations "portrait,portrait upside down"
   end if
end preopencard

on opencard
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

on resizeStack
   lock screen
   setCardCoords
   updateUI
   unlock screen
end resizeStack

on updateUI
   local tFooter, tHeader, tRect, tControl, tWidth, tLoc
   put CardWidth() into tWidth
   
   put the long id of grp "headerGrp" into tHeader
   set the width of tHeader to CardWidth()
   topCenterMe tHeader
   
   put the long id of grp "footerNavigation" into tFooter
   send "updateUI" to tFooter
   
   set the rect of grc "calDisplayBkgnd" to \
         (0,0,tWidth,the top of tFooter)
   set the rect of grp "main-calendar-view" to \
         (14,the bottom of tHeader + 10,tWidth - 14,the top of tFooter - 10)
   
   put the long id of grp "city-picker-view" into tControl
   put the loc of tControl into tLoc
   put horizCenter() into item 1 of tLoc
   set the loc of tControl to tLoc
end updateUI
