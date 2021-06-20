script "behavior_SurpriseAudio"
local sTimestamp,sAudioPlay


on preOpenCard
   hide fld "audioDetails"
   pass preOpenCard
end preOpenCard


on opencard
   --breakpoint
   if isMobile() then
      deleteMobileControl "audioPlayer" # in case one is open already and playing
   end if  
   togglePause false, true
   put empty into fld "audioDetails"  
   
   if connectivity_PingServer() = "false" then
      dialog_CustomMsg "Sorry, an Internet connection is required to view this content. You can view Verses offline instead."
      go to card "surprise_verses"
   else
      getRandomAudio
   end if
   pass openCard
end opencard


on getRandomAudio
   
   if isMobile() then
      mobileClearTouches
   end if
   
   local gotIt, tURL
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
      exit to top
   end if
   
   --breakpoint
   
   mediaUrl_Set tURL
   
   
   wait for 200 milliseconds
  
   startAudioPlayer tURL
end getRandomAudio


on startAudioPlayer pURL, pTimestamp
   
   --breakpoint
   if isMobile() then
      createMobileAudioPlayer pURL, "audioPlayer"
      getPlaying true
   else
      set the filename of player "audioPlayer" to pURL
      start player "audioPlayer" 
      getPlaying true
   end if
   
   
   showAudioDetails
   
   ntInfo "showing audio toggler"
   togglePause true, true
   
   showBusyIndicator false
   
   
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
   
   dispatch "CreateScroller" to fld "audioDetails" with "AudioDetails"
   
   show fld "audioDetails" with visual effect "reveal right"
end showAudioDetails


command share_Items
   local tShareItemsA
   put mediaUrl_Get() into  tShareItemsA["url"]  
   put "Awesome Audio!" into tShareItemsA["subject"]
   put  "From the SivaSiva app." & cr & cr & fld "audioDetails" into tShareItemsA["text"]
   return tShareItemsA
end share_Items
