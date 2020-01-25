Script "stack_color-meditation_card_id_1023"

/*
# Name: card "colorPreferences" of stack "color-meditation"
# ID: card id 1023 of stack "color-meditation"
*/


global gUserSettings

on preopencard
   local tSettings
   # Virtual Prop call
   put the uReturnUserSettings of me into tSettings 
   -- clean up UI
   put empty into fld "completionTime"
   showCommitment
   insertUserPreferences
   pass preOpenCard
end preopencard

command showCommitment
   local tCurrentLevelTime, tTotalSeconds, tLevel, tMinutes
   put calculateTimeToCompletion()  into tCurrentLevelTime
   put item 1 of tCurrentLevelTime into tTotalSeconds
   put item (item 2 of tCurrentLevelTime) of ("Primary Colors","Tertiary Colors","Transmute to White")  into tLevel
   if tTotalSeconds <60 then 
      put  "0" into tMinutes
   else
      put trunc(tTotalSeconds/60) into tMinutes
      put tTotalSeconds mod 60 into tTotalSeconds
   end if
   put  tLevel & cr & tMinutes && "min" && tTotalSeconds&&"seconds" into fld "completionTime"
end showCommitment

command insertUserPreferences
   local aSettings
   put getUserPreferences() into aSettings
   put aSettings["breathCount"] into fld "currentCount"
   put aSettings["breathPace"] into fld "currentPace"
   put aSettings["cycles"] into fld "currentCycles"
   put aSettings["audioOn"] into fld "currentAudio"
end insertUserPreferences
