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
      createMobileAudioPlayer pURL, "audioPlayer"
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
   put textDecode (getMediaItemMetadata(),"UTF8") into  fld "audioDetails" 
   set the textsize of line 1 of fld "audioDetails" to 22
   set the textstyle of line 1 of fld "audioDetails" to "bold"
   set the textstyle of line 3 of fld "audioDetails" to "italic"
   
   # need to fix this because the height could be too tall
   # if too tall we need to set max height
   # and instantiate scrolling on desktop and mobile
   
   put the formattedHeight of fld "audioDetails" into tRequiredHeight
   
   If tRequiredHeight> 512 then
      # We need to constrain size and set scrolling
      # BR: I'm making an attempt here to see if we can accomodate Tablet
      # by working with the card size instead of setting a fixed pixel rect.
      
      set the rect of fld "AudioDetails" to (45,65,the width of this card-45,the height of this card -150) 
      set the vscrollbar of fld "AudioDetails" to not isMobile()
      
      dispatch "CreateScroller" to fld "audioDetails" with  "AudioDetails"
      
   else  # it will fit
      set the height of fld "audioDetails" to tRequiredHeight
      if tRequiredHeight > 400 then # too tall to center. falls behind the player controller
         set the top of fld "AudioDetails" to 66
      else
         set the loc of fld "audioDetails" to the loc of this card
      end if
   end if
   show fld "audioDetails" with visual effect reveal right
end showAudioDetails

command share_Items
   put mediaUrl_Get() into  sShareItemsA["url"]  
   put "Awesome Audio!" into sShareItemsA["subject"]
   put  "From the SivaSiva app." & cr & cr & fld "audioDetails" into sShareItemsA["text"]
   return sShareItemsA
end share_Items
