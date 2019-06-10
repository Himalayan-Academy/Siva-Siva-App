Script "stack_view_SivaSivaBrowser_button_id_1408"

/*
# Name: button "Change URL" of card id 1405 of stack "view_SivaSivaBrowser"
# ID: button id 1408 of card id 1405 of stack "view_SivaSivaBrowser"
*/


on menuPick pChoice
   set the url of widget "body" of card 1 to \
         fld ("url"&pChoice)
   go to card 1
end menuPick
