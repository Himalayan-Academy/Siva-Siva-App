Script "stack_Siva-Siva-App_button_id_10010"

/*
# Name: button "Reset Original" of card "Global Image Resource 1" of stack "Siva-Siva-App"
# ID: button id 10010 of card id 7644 of stack "Siva-Siva-App"
*/


constant kButtonIconIDs="7648,7649,7650,10000,7653,10002,10003,10004,10006,10007"

on Mouseup
   repeat for each item x in kButtonIconIDs
      select control id x
      
      
      answer file "Select the image you wish to view:" with type "JPEG Images|jpg|JPEG"
      
      if it is "Cancel" then
         exit to top
      else
         put it into tFilename
         set the filename of control id x to tFilename
      end if
      end repeat
      --      reImportFullSize
      --      createEmbedAndCrop
      
   end Mouseup

command reImportFullSize
   
end reImportFullSize

   command createEmbedAndCrop
   Create image "gems"
   set the loc of grc "newCrop" to the loc of img "tempImage"
   put url("binfile:" & the filename of img "tempImage") into img "gems"
   set the loc of img "gems" to the loc of img "tempImage"
   --crop image "gems" to the rect of grc "newCrop"
end createEmbedAndCrop

