script "behavior_JournalEntry"
on mouseUp
   put the cEntry of the target into tA
   launchActivity tA
end mouseUp


on launchActivity pA
   setJournalFlag 1
   portal_SetCurrentStack "journal"
   set the acceleratedRendering of this stack to false
   Journal_LaunchEntry pA["journal_id"]
   
   if the result contains "err" then
      answer error the result
   end if
end launchActivity
