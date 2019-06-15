Script "stack_surprise_card_id_1037"

/*
# Name: card "surprise_art" of stack "surprise"
# ID: card id 1037 of stack "surprise"
*/


on preopencard
   hide img "surprise-art"
end preopencard

on opencard
   if connectivity_PingServer() = "false" then
      dialog_CustomMsg "Connection required. Going to Verses"
      go to card "surprise_verses"
   else
      getAnImage
   end if
   pass opencard
end opencard

on closeCard
   set the loc of image "surprise-art" to the loc of this card
   set the filename of img "surprise-art" to empty
end closeCard

command getAnImage
    showBusyIndicator true
      hide grp "go-next"
      put the long id of img "surprise-art" into tImgTarget
      hide image "surprise-art" with visual effect dissolve very fast
      put fetchRandomMediaItem ("media_type","art/painting") into gotIt
      put getMediaURL ("med,whatever") into sURL
      set the filename of img "surprise-art" to sURL
      mediaUrl_Set sURL
      
      insertImageDimensions (the long ID of img "surprise-art")
      mediaUrl_Set sURL
      if the formattedwidth of tImgTarget > the width of this card then
         put "true" into tSizeIsBig
         toggleImgSize tImgTarget,tSizeIsBig,(the width of this card) 
      end if
          showBusyIndicator false
      set the loc of img "surprise-art" to the loc of this card
      send showDarshan  to me in  20 milliseconds
end getAnImage

command showDarshan
   show img "surprise-art"  with visual effect reveal right very fast
    show grp "go-next"
end showDarshan

command share_Items 
   put mediaUrl_Get() into  sShareItemsA["url"]  
   put "Look at This!" into sShareItemsA["subject"]
   put "Images from the SivaSiva app." into sShareItemsA["text"] 
   return sShareItemsA
end share_Items


