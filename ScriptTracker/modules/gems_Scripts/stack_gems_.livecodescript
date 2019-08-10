Script "stack_gems_"

/*
# Name: stack "gems"
# ID: stack "gems"
*/


on preopenstack
   if isMobile() then
      mobileHideStatusBar
   end if
end preopenstack

on closestack
   portal_SetLastStack "gems" 
end closestack

on journalResume  pDataA, pEntryA
   dispatch "restoreFromJournalEntry" to card "images-quotes" with pDataA
end journalResume

on resizeStack
   lock screen
   setCardCoords
   updateUI
   unlock screen
end resizeStack

on updateUI
   local tFooter, tQuote, tRect, tControl
   put the long id of grp "footerNavGroup" into tFooter
   set the width of tFooter to CardWidth()
   bottomCenterMe tFooter
   put the long id of grp "quoteControl" into tControl
   put (0,321,CardWidth(),CardHeight()) into tRect
   set the rect of tControl to tRect
   if there is a control "Title" then
      put the long id of fld "Title" into tControl
      topCenterMe tControl, 7
      put the long id of btn "goNextRealm" into tControl
      topRightMe tControl
      put the long id of btn "loadContext" into tControl
      topLeftMe tControl
      set the rect of btn "cancel" to the rect of tControl
      set rect of widget "readContext" to (10, the bottom of btn "cancel" + 6, \
            CardWidth() - 10, the top of tFooter - 10)
   end if
end updateUI
