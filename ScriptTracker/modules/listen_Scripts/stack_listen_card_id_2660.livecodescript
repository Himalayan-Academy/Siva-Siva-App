Script "stack_listen_card_id_2660"

/*
# Name: card "listen-file" of stack "listen"
# ID: card id 2660 of stack "listen"
*/


local sTimestamp,sURL,sSelectedItemA

on opencard
   
   if isMobile() then
      deleteMobileControl "audioPlayer" # in case one is open already and playing
   end if  
   hide fld "audioDetails"
   togglePause false, true
   put empty into fld "audioDetails"  
   log getMediaMeta()

end opencard

command playSingle pDataA
   local tSearchA,x,item_id
   put empty into sSelectedItemA
   
   put pDataA["url"] into sURL
   put pDataA["item_id"] into tSearchA["item_id"]
   put fetchMediaItems(tSearchA) into sSelectedItemA
   startPlayer sURL,pDataA["title"] 
   select_ShowDetails  "downloaded"
end playSingle

on closeCard
   hide fld "audioDetails"
   put empty into fld "audioDetails"
   togglePause true, true
end closeCard

command share_Items
   local tShareItemsA
   put mediaUrl_Get() into  tShareItemsA["url"]  
   put "Awesome Audio!" into tShareItemsA["subject"]
   put  "From the SivaSiva app." & cr & cr & fld "audioDetails" into tShareItemsA["text"]
   return tShareItemsA
end share_Items


