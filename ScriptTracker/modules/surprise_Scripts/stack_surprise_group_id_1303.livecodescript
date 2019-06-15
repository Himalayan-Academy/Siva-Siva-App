Script "stack_surprise_group_id_1303"

/*
# Name: group "verse-collections" of card "surprise_verses" of stack "surprise"
# ID: group id 1303 of card id 1002 of stack "surprise"
*/


local sCollection
on mouseup
   put the short name of the target into tCollection
   switch tCollection
      case "Auvaiyar"
         put "Atti Chudi" into sCollection
         break
      case "Yogaswami" 
         put "Words of Our Master" into sCollection
         break
      default
         put tCollection into sCollection # not really needed, but...
   end switch
   setCurrentCollection sCollection
 --  journal_AddEntry
   insertRandomVerse
end mouseup

-- on journal_AddEntry
--    put "surprise_verse" into pDataA["card"]
--    --put the short name of this card into pDataA["card"]
--    put sCollection into pDataA["collection"]
--    put "Sacred Verses-" & sCollection into tJournalTitle
--    Journal_RecordEntry "surprise", tJournalTitle, pDataA
-- end journal_AddEntry

on insertRandomVerse
   put getCurrentCollection() into tCollection
   fetchRandomQuote (tCollection)
   # get it over there first
   send "setUpQuote" to card "surprise_verse"
   go next card
   put "surprise-random-"& tCollection into pTrackdata["contentTarget"]
   tracking_RecordActivity "Surprise", "navigation/gocontent", pTrackdata
end insertRandomVerse
