Script "stack_listen_card_id_2660"

/*
# Name: card "listen-file" of stack "listen"
# ID: card id 2660 of stack "listen"
*/


local sTimestamp,sURL

on opencard
   if isMobile() then
      deleteMobileControl "audioPlayer" # in case one is open already and playing
   end if  
   hide fld "audioDetails"
   togglePause false, true
   put empty into fld "audioDetails"  
end opencard

command playSingle pDataA
   
   put pDataA["Title"] into fld "audioDetails"
   put pDataA["url"] into sURL
   startAudioPlayer sURL
end playSingle

on startAudioPlayer sURL, pTimestamp
   #  later we can set the metadata for the audiodetail
   show graphic "Loading..."
   if connectivity_PingServer() = "false" then
      dialog_CustomMsg "Sorry, an Internet connection is required to view this content."
      go to card "listen-my-audio"
      exit to top
   end if
   
   if isMobile() then
      createMobileAudioPlayer SURL, "audioPlayer"
   else
      set the filename of player "audioPlayer" to sURL
      start player "audioPlayer"
      togglePause true, true
   end if
   hide graphic "Loading..."
   send "showAudioDetails" to me in 50 millisecondS
   
   
   --setMobileAudioPlayer "audioPlayer",  "play", pTimestamp
end startAudioPlayer

on closeCard
   hide fld "audioDetails"
   put empty into fld "audioDetails"
   togglePause true, true
end closeCard

command showAudioDetails
   local tRequiredHeight, tPlayerRect, tAvailableHeight
   put textDecode (getMediaItemMetadata(),"UTF8") into  fld "audioDetails" 
   set the textsize of line 1 of fld "audioDetails" to 22
   set the textstyle of line 1 of fld "audioDetails" to "bold"
   set the textstyle of line 3 of fld "audioDetails" to "italic"
   
   # need to fix this because the height could be too tall
   # if too tall we need to set max height
   # and instantiate scrolling on desktop and mobile
   
   set the width of of fld "audioDetails" to CardWidth() - 90
   put the formattedHeight of fld "audioDetails" into tRequiredHeight
   
   if isMobile() then
      put getMobileAudioPlayerRect() into tPlayerRect
   else
      put the rect of player "audioPlayer" into tPlayerRect
   end if
   put item 2 of tPlayerRect - safeTopMargin() - 96 into tAvailableHeight
   
   if tRequiredHeight > tAvailableHeight then
      # We need to constrain size and set scrolling
      # BR: I'm making an attempt here to see if we can accomodate Tablet
      # by working with the card size instead of setting a fixed pixel rect.
      
      set the rect of fld "AudioDetails" to \
            (45, 65 + safeTopMargin(), CardWidth() - 45, item 2 of tPlayerRect - 21) 
      
      dispatch "CreateScroller" to fld "audioDetails" with  "AudioDetails"
      
   else  # it will fit
      set the height of fld "audioDetails" to tRequiredHeight
      set the left of fld "audioDetails" to 45
      set the top of fld "audioDetails" to \
            (tAvailableHeight-tRequiredHeight)/2 + safeTopMargin() + 65
   end if
   set the vscrollbar of fld "AudioDetails" to not isMobile()
   show fld "audioDetails" with visual effect "reveal right"
end showAudioDetails



command share_Items
   local tShareItemsA
   put mediaUrl_Get() into  tShareItemsA["url"]  
   put "Awesome Audio!" into tShareItemsA["subject"]
   put  "From the SivaSiva app." & cr & cr & fld "audioDetails" into tShareItemsA["text"]
   return tShareItemsA
end share_Items
