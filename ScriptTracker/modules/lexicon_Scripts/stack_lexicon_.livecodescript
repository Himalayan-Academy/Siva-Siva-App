Script "stack_lexicon_"

/*
# Name: stack "lexicon"
# ID: stack "lexicon"
*/


command addJournalEntry -- save a bookmark to db
   local tTitle,pData
   put "Lexicon" into tTitle
   put "MainCard" into pData["Card"]
   Journal_RecordEntry "lexicon",(tTitle), pData -- send to journal
end addJournalEntry
		
on journalResume pData -- sent from journal stack
   local tCD
   put pData["Card"] into tCd
   go to card tCd
end journalResume

on closeStack
   portal_SetLastStack "lexicon"
end closeStack


