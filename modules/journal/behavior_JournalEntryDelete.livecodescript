script "behavior_JournalEntryDelete"
local tA

on mouseUp
   put the cEntry of the target into tA
   deleteEntry tA
end mouseUp


on deleteEntry pA
   
   Journal_DeleteEntry pA["journal_id"]
   send "refreshUI" to card (the currentcard of stack "journal") of stack "journal" in 20 ticks
   
end deleteEntry
