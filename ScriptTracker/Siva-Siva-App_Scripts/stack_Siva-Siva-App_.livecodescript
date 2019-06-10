Script "stack_Siva-Siva-App_"

/*
# Name: stack "Siva-Siva-App"
# ID: stack "Siva-Siva-App"
*/


on mobileStandaloneSaved
   set the beepPitch to 300
   set the beepDuration to 2000
   beep 2
end mobileStandaloneSaved

on closestack
   local tDate
   if isMobile() then
      put the long Date into tDate
      tracking_RecordActivity "Siva-Siva-App", "shutdown/exit", tDate
   end if
end closestack
