Script "stack_listen_card_id_2660"

/*
# Name: card "listen-file" of stack "listen"
# ID: card id 2660 of stack "listen"
# Behavior: stack "behavior_ListenSelectPlay"
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
   
   local tSearchA,x,tItem_id
   put empty into sSelectedItemA
   
   put pDataA["url"] into sURL
   put pDataA["item_id"] into tItem_id
   
   startPlayer sURL,pDataA["title"]
   showBusyIndicator false
   if  "audio/book" is not in sURL then # no display details
      select_ShowDetails "downloaded"
   end if 
end playSingle

on closeCard
   put empty into fld "audioDetails"
   hide fld "audioDetails"
   put empty into fld "audioDetails"
   put empty into fld "currentTitleLabel"
   togglePause true, true
end closeCard

command share_Items
   local tShareItemsA
   put mediaUrl_Get() into  tShareItemsA["url"]  
   put "Awesome Audio!" into tShareItemsA["subject"]
   put  "From the SivaSiva app." & cr & cr & fld "audioDetails" into tShareItemsA["text"]
   return tShareItemsA
end share_Items


