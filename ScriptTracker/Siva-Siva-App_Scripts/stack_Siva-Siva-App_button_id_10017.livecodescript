Script "stack_Siva-Siva-App_button_id_10017"

/*
# Name: button "test for files" of card "development" of stack "Siva-Siva-App"
# ID: button id 10017 of card id 4075 of stack "Siva-Siva-App"
*/


on mouseup
   put (path_Documents() & "media/audio") into pFolder
   put listFilesWithPaths(pFolder, "true")  into tList
   put tList
end mouseup
