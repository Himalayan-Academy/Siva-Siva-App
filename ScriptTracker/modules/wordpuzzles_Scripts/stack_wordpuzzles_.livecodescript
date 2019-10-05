Script "stack_wordpuzzles_"

/*
# Name: stack "wordpuzzles"
# ID: stack "wordpuzzles"
*/


local thePixie,tFadeIncrement,sPixies,sPuzzleLevel,sCardRect

on preOpenStack
   if isMobile() then
      mobileSetAllowedOrientations "landscape left,landscape right" 
      mobileSetFullScreenRectForOrientations "landscape left,landscape right","0,0,736,414"
      set the fullscreenmode of this stack to "showAll" -- better for wider screens
   end if
   hide grc "blankScreen"
end preOpenStack

on closeStack
   local pTrackdata -- BWM looks like something is missing
   addJournalEntry
   tracking_RecordActivity "Word Puzzles", "navigation/exit", pTrackdata
   if isMobile() then
      mobileSetFullScreenRectForOrientations "landscape left,landscape right"
   end if
   portal_SetLastStack "wordpuzzles"
end closeStack

function getUserPreferences
   local aWordPuzzleLevel
   put getPref ("preferences/modules/word-puzzle") into aWordPuzzleLevel
   put aWordPuzzleLevel["level"] into sPuzzleLevel
   return sPuzzleLevel
end getUserPreferences

command saveUserPrefs sPuzzleLevel
   setPref "preferences/modules/word-puzzle/level", sPuzzleLevel
   get getUserPreferences()
end saveUserPrefs

command storeCurrentLevel pLevel
   put pLevel into sPuzzleLevel
end storeCurrentLevel

command addJournalEntry 
   local pData, tTitle
   put "word-puzzle" into pData["card"]
   put "Word Puzzles" into tTitle
   Journal_RecordEntry "wordpuzzles",tTitle,pData -- send to journal
end addJournalEntry

on journalResume pDataA, pEntryA
   local pLevel -- BWM looks like this value is unused
   go to card  pDataA["card"] 
   put pDataA["lastLevel"] into pLevel
end journalResume
