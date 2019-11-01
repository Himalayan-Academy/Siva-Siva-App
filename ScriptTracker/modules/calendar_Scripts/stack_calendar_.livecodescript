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

on resizeStack
   lock screen
   setCardCoords
   updateUI
   unlock screen
end resizeStack

on updateUI
   local tFooter, tHeader, tRect, tControl
   put the long id of grp "headerGrp" into tHeader
   set the width of tHeader to CardWidth()
   topCenterMe tHeader
   
   put the long id of grp "footerNavigation" into tFooter
   set the width of tFooter to CardWidth()
   bottomCenterMe tFooter
   
   set the rect of grc "calDisplayBkgnd" to \
         (0,0,CardWidth(),the top of tFooter)
   set the rect of grp "main-calendar-view" to \
         (14,the bottom of tHeader + 10,CardWidth() - 14,the top of tFooter - 10)
   
   --   put the long id of grp "quoteControl" into tControl
   --   put (0,321,CardWidth(),CardHeight()) into tRect
   --   set the rect of tControl to tRect
   --   if there is a control "Title" then
   --      put the long id of fld "Title" into tControl
   --      topCenterMe tControl, 7
   --      put the long id of btn "goNextRealm" into tControl
   --      topRightMe tControl
   --      put the long id of btn "loadContext" into tControl
   --      topLeftMe tControl
   --      set the rect of btn "cancel" to the rect of tControl
   --      set rect of widget "readContext" to (10, the bottom of btn "cancel" + 6, \
   --            CardWidth() - 10, the top of tFooter - 10)
   --   end if
end updateUI
