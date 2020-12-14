script "behavior_JournalEntryDelete"

on mouseUp
   put the cEntry of the target into tA
   deleteEntry tA
end mouseUp


on deleteEntry pA
   
   Journal_SetFavoriteFlag pA["journal_id"], tValue
   
end deleteEntry
