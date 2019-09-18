Script "stack_daily-lesson_"

/*
# Name: stack "daily-lesson"
# ID: stack "daily-lesson"
*/


local sLastActivityA

on preopenstack
   if isMobile() then    
      mobileSetAllowedOrientations "portrait,portrait upside down"
   end if
end preopenstack

on opencard
   audioIsRunning  
end opencard

on setLastactivity  pLessonNum, pCdName  
   put pCdName into sLastActivityA["CdName"]
   put pLessonNum into sLastActivityA["LessonNum"]
end setLastactivity

command resetUI
   put empty into fld "title"
   put empty into fld "daily-lesson-text"
end resetUI

on closeStack
   addJournalEntry
   portal_SetLastStack "daily-lesson" 
end closeStack

# more than needed but we may expand activities in this module later
# so keeping Jacque's nice construct for now.

command addJournalEntry -- save a bookmark to db
   local tCdName, tData, tTitle
   put sLastActivityA["CdName"] into tCdName
   put tCdName into tData["card"] -- store the last user cd   
   if tCdName = "daily-lesson" then -- store the lesson number
      --put sLastActivityA["LessonNum"] into tLessonNum
      --put tLessonNum into tData["lessonNum"]
      --put "Master Course Dialy Lesson - " & tLessonNum into tTitle -- "lesson x"
      put "Master Course Daily Lesson"  into tTitle
   end if
   Journal_RecordEntry "daily-lesson",tTitle,tData -- send to journal
end addJournalEntry


on journalResume pData,pEntryA -- sent from journal stack
   local tCd
   put pData["card"] into tCd
   go to card tCd
   --put pData["lessonNum"] into tNum
   --send "fetchLessonAndImage tNum" to this cd
   
end journalResume

on closeStack
   portal_SetLastStack "daily-lesson"
end closeStack
