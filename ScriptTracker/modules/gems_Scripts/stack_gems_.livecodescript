Script "stack_gems_"

/*
# Name: stack "gems"
# ID: stack "gems"
*/


on preopenstack
   set the fullscreenmode of this stack to "showAll"
   if isMobile() then    
      mobileSetFullScreenRectForOrientations "portrait,portrait upside down","0,0,414,736"
      set the fullscreenmode of this stack to "showAll"
   end if
end preopenstack

on closestack
   portal_SetLastStack "gems" 
end closestack

on journalResume  pDataA, pEntryA
   dispatch restoreFromJournalEntry to card "images-quotes" with pDataA
end journalResume
