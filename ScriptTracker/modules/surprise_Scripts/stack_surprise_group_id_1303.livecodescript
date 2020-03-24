Script "stack_surprise_group_id_1303"

/*
# Name: group "verse-collections" of card "surprise_verses" of stack "surprise"
# ID: group id 1303 of card id 1002 of stack "surprise"
*/


local sCollection

on mouseup
   local tCollection, tTrackdata
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
   put "surprise-random-"& sCollection into tTrackdata["contentTarget"]
   tracking_RecordActivity "Surprise", "navigation/gocontent", tTrackdata
end mouseup

