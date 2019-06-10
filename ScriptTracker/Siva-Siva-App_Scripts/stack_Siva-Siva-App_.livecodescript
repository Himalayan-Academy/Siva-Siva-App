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
   if isMobile then
      put the long Date into pData
      tracking_RecordActivity "Siva-Siva-App", "shutdown/exit",  pDate
   end if
end closestack
