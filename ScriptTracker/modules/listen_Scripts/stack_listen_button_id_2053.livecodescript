Script "stack_listen_button_id_2053"

/*
# Name: button "Misc Tests" of group "devtools" of card "listen-search" of stack "listen"
# ID: button id 2053 of group id 2043 of card id 2052 of stack "listen"
*/


local sSelectionsA

on mouseUp
   put checkPlayList()
 --  cleanUpGui
 --  typeSetAudioTitleList
   --resetlines
end mouseUp

on typeSetAudioTitleList
   repeat with x = 1 to the number of lines of fld "audioList"
      set the spacebelow of line x of fld "audioList" to 8
   end repeat
end typeSetAudioTitleList

-- put playlist_GetCurrent into tPlayList
 -- playlist_QuerySetUp tPlayList

--  testForRecords
-- put sivasiva_FetchData()

on  makeSelection pNum
   put playlist_GetRecords() into sSelectionsA 
   put sSelectionsA[pNum]["title"] into fld "currentTitleLabel"
end makeSelection


on fetchPlayList
   put fetchMediaItems (media_type,inspiredtalk,author,Bodhinatha) into aCompletePlayList
   get the keys of aCompletePlayList
   sort lines of it numeric descending by aCompletePlayList[each]["item_id"]
   put it into tNewOrder
   put 0 into tCount
   repeat for each line tLine in tNewOrder
      #... create the new array
      put aCompletePlayList[tLine]["item_id"] & cr after tNewList
      add 1 to tCount
   end repeat
end fetchPlayList

on getPlayListThumb
     put playlist_GetCurrent() into tTitle
      put sivasiva_FetchData() into tPortalInfoA
      put tPortalInfoA["portalRowDictionary"][tTitle][shortImageFile] into tThumbPath
      put path_Assets() & "img/portal-screens/" & tThumbPath into tPosterPath
      set the filename of img "playlistPoster" to tPosterPath
   end getPlayListThumb
   
on fetchRemoteList
         put "{'data': {'media_type': 'inspiredtalk','author':'Bodhinatha'},'recordType':'latest','recordCount':'30'}" into pJSON
            put the seconds into sStartTimer
            set the httpheaders to "content-type: application/json"
            replace "'" with quote in pJSON
            POST pJSON to URL "http://dev.himalayanacademy.com/api3/getItemRecords/json"
            if the result is not empty then 
               put the result into fld "audioList"
               # reveal field using the function after it is built later      
            else 
               put it into tRecords
               put jsonToArray(tRecords) into sCurrentPlayListA
           
            end if
   end fetchREmoteList
