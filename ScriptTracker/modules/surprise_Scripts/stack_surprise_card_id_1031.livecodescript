Script "stack_surprise_card_id_1031"

/*
# Name: card "surprise_audio" of stack "surprise"
# ID: card id 1031 of stack "surprise"
*/


on opencard
   if isMobile() then
      deleteMobileControl "audioPlayer" # in case one is open already and playing
   end if  
   put empty into fld "audioDetails"  
   
   if connectivity_PingServer() = "false" then
      dialog_CustomMsg "Sorry, an Internet connection is required to view this content. You can view Verses offline instead."
      go to card "surprise_verses"
   else
      getRandomAudio
   end if
end opencard

on getRandomAudio
   local gotIt, tURL
   hide fld "audioDetails"
   -- showBusyIndicator true,"Loading"
   
   # Test UTF8 Diacriticals
   # fetchRandomMediaItem ("media_type","audio", "file_id","guruparampara-vandana_pmp")
   
   # Test with record that has commas in description:
   # fetchRandomMediaItem ("media_type","audio", "file_id","gr_2000-10-09_culture-crisis")   
   --fetchRandomMediaItem ("media_type","audio", "item_id","2023")
   
   put fetchRandomMediaItem ("media_type","audio","approved_for_public","YES") into gotIt
   put getMediaURL () into tURL
   if tURL = "" then -- jg: don't continue
      put "Media not found" into fld "audioDetails"
      set the height of fld "audioDetails" to the formattedHeight of fld "audioDetails"
      --    showBusyIndicator false
      exit to top
   end if
   mediaUrl_Set tURL
   send "showAudioDetails" to me in 1 second
   startAudioPlayer tURL
   
end getRandomAudio

on startAudioPlayer pURL, pTimestamp
   if connectivity_PingServer() = "false" then
      dialog_CustomMsg "Sorry, an Internet connection is required to view this content. You can view Verses offline instead."
      go to card "surprise_verses"
      exit to top
   end if
   
   if isMobile() then
      createMobileAudioPlayer pURL, "audioPlayer", getPlayerRect()
   else
      set the filename of player "audioPlayer" to pURL
   end if
   if not isMobile() then 
      show player "audioPlayer"
      start player "audioPlayer"
   else
      setMobileAudioPlayer "audioPlayer",  "play", pTimestamp
   end if
end startAudioPlayer
  
on closeCard
   -- journal_AddEntry
   hide fld "audioDetails"
   put empty into fld "audioDetails"
   showPlayer "false", "audioPlayer"
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
