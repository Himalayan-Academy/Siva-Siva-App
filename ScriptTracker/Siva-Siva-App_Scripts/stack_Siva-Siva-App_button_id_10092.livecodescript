Script "stack_Siva-Siva-App_button_id_10092"

/*
# Name: button "prepareImageGrp1" of card "Global Image Resource 1" of stack "Siva-Siva-App"
# ID: button id 10092 of card id 7644 of stack "Siva-Siva-App"
*/


on Mouseup
   put the childControlNames of group "globalImageGrp1"  of cd "Global Image Resource 1" of stack "Siva-Siva-App" into tImagesToPrep
   repeat for each line x in tImagesToPrep
      put the filename of image x & cr after tOutput
      --prepare image x
   end repeat
   put tOutPut
end Mouseup




