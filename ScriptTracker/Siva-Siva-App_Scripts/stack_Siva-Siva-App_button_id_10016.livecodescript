Script "stack_Siva-Siva-App_button_id_10016"

/*
# Name: button "Get image List" of card "Global Image Resource 1" of stack "Siva-Siva-App"
# ID: button id 10016 of card id 7644 of stack "Siva-Siva-App"
*/


on mouseup
   repeat with x = 1 to (the number of images on this card)
      put the short Name  of img x & cr after tImageList
   end repeat
   put tImageList
end mouseup

