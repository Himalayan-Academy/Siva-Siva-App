script "behavior_WordPuzzles"
local thePixie,tFadeIncrement,sPixies,sPuzzleLevel,sCardRect

on preOpenStack
   if isMobile() then
      mobileSetAllowedOrientations "landscape left,landscape right" 
      mobileSetFullScreenRectForOrientations "landscape left,landscape right","0,0,736,414"
      set the fullscreenmode of this stack to "showAll" -- better for wider screens
   end if
   hide grc "blankScreen"
   setCardCoords "landscape"
end preOpenStack

on closeStack
   local pTrackdata -- BWM looks like something is missing
   tracking_RecordActivity "Word Puzzles", "navigation/exit", pTrackdata
   if isMobile() then
      mobileSetFullScreenRectForOrientations "landscape left,landscape right"
   end if
   portal_SetLastStack "wordpuzzles"
end closeStack

command loadNewBgImg -- change img for each new puzzle
   -- called by createWordPuzzle
   --if not (the lockscreen)  then lock screen
   local pControl, tFolderPath, tFiles, tImgPath
   ntInfo (" loadNewBgImg: lockscreen: " & the lockscreen)
   put the long id of img "bgImage" into pControl
   put path_Assets() & "/img/bkgnds/nature/landscape/"   into tFolderPath
   put files(tFolderPath) into tFiles
   put any line of tFiles into tImgPath
   set the filename of img "bgImage" to tFolderPath&tImgPath
   --if (the lockscreen)  then unlock screen
end loadNewBgImg


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
   dialog_CustomMsg "Saved to Journal"
end addJournalEntry

on journalResume pDataA, pEntryA
   local pLevel
   go to card  pDataA["card"] 
   put pDataA["lastLevel"] into pLevel
end journalResume
