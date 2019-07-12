Script "stack_gems_"

/*
# Name: stack "gems"
# ID: stack "gems"
*/


on preopenstack
   --   set the fullscreenmode of this stack to "showAll"
   --   if isMobile() then    
   --      mobileSetFullScreenRectForOrientations "portrait,portrait upside down","0,0,414,736"
   --      set the fullscreenmode of this stack to "showAll"
   --   end if
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
   put the long id of grp "footerNav" into tFooter
   set the width of tFooter to CardWidth()
   bottomCenterMe tFooter
   put the long id of grp "quoteControl" into tControl
   put (0,321,CardWidth(),CardHeight()) into tRect
   set the rect of tControl to tRect
   --put the long id of fld "gems-quote" of grp "quoteControl" into tQuote
   --put the rect of tQuote into tRect
   --put (item 2 of the rect of tFooter) - 12 into item 4 of tRect
   --set the rect of tQuote to tRect
   if there is a control "Title" then
      put the long id of grc "portal-title-bkgnd" into tControl
      topCenterMe tControl
      put the long id of fld "Title" into tControl
      topCenterMe tControl, 7
      put the long id of btn "loadContext" into tControl
      topLeftMe tControl
      put the long id of btn "goNextRealm" into tControl
      topRightMe tControl
   end if
end updateUI
