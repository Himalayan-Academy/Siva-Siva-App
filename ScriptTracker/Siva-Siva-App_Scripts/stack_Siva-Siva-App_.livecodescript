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
   
   --> being brand image handling
   
   # store and increment the BrandImage
   # the card script of the home Portal handles
   # set the number and paths and
   # the display from the preferences
   put getPref ("preferences/modules/portal/brandImageNumber") into tBrandImage
   put getCache("TotalBrandImages") into tTotal
   if tBrandImage > tTotal then
      put 1 into tBrandImage
   else
      add 1 to tBrandImage
   end if
   
   setPref "preferences/modules/portal/brandImageNumber", tBrandImage
   
   --> end brand image handling
   
   if isMobile() then
      put the long Date into tDate
      tracking_RecordActivity "Siva-Siva-App", "shutdown/exit", tDate
   end if
end closestack
