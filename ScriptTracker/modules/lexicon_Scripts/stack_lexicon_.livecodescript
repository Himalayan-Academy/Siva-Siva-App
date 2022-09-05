Script "stack_lexicon_"

/*
# Name: stack "lexicon"
# ID: stack "lexicon"
*/



command Journal_AddEntry -- save a bookmark to db
   local  tBrowser, tTitle, pData
   
   put the long id of widget "Browser" of card "mainCard"into tBrowser
   
   --moveMe  tBrowser, 0, 50, 200
   
   put "Lexicon" into tTitle
   put "loader" into pData["Card"]
   
   answer "Shortcuts?" with  "No" or "Yes" 
   
   
   
   if it is "Yes" then
      
      Journal_RecordEntry "lexicon",(tTitle), pData -- send to journa
      
      dialog_CustomMsg "Saved to Shortcuts"
   end if
   --moveMe tBrowser, 0, -50, 200
   
end Journal_AddEntry	
	
on journalResume pData -- sent from journal stack
   local tCD
   put pData["Card"] into tCd
   go to card tCd
end journalResume

on closeStack
   portal_SetLastStack "lexicon"
end closeStack


