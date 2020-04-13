Script "stack_surprise_card_id_1039"

/*
# Name: card "surprise_darshan" of stack "surprise"
# ID: card id 1039 of stack "surprise"
*/


on preopencard
   hide img "surprise-image"
  pass preopencard
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
   set the loc of image "surprise-image" to the loc of this card
   set the filename of img "surprise-image" to empty
end closeCard

command getAnImage 
   local tImgTarget, tCollections,tCollection,GotIt,sURL, tSizeIsBig
   showBusyIndicator true, "Loading Darshan"
   put the long id of img "surprise-image" into tImgTarget
   hide img "surprise-image" with visual effect "dissolve" very fast
   put "Subramuniyaswami,Bodhinatha,Deities" into tCollections
   put item ( random(3) ) of tCollections into tCollection
   put fetchRandomMediaItem ("media_type","art/photography","tags",tCollection) into GotIt
   put getMediaURL ("med,whatever") into sURL
   set the filename of img "surprise-image" to sURL
   insertImageDimensions (the long ID of img "surprise-image")
   mediaUrl_Set sURL
   if the formattedwidth of tImgTarget > the width of this card then
      put "true" into tSizeIsBig
      toggleImgSize tImgTarget,tSizeIsBig,(the width of this card) 
   end if     
   showBusyIndicator false
   set the loc of img "surprise-image" to the loc of this card
   send "showSurprise"  to me in  20 milliseconds
   if isMobile() then
      mobileClearTouches
   end if
 
end getAnImage

command showSurprise
   show img "surprise-image"  with visual effect "reveal right" very fast
   set layer of grp "go-next" to  top
   log ("go next: layer: " & the layer of grp "go-next" & " vis: "  & the vis of group "go-next" of me & "; Rect: "  & the rect of group "go-next" of me)
end showSurprise

command share_Items 
   local  sShareItemsA
   put mediaUrl_Get() into  sShareItemsA["url"]  
   put "Look at This!" into sShareItemsA["subject"]
   put "Darshan from SivaSiva app." into sShareItemsA["text"] 
   return sShareItemsA
end share_Items

