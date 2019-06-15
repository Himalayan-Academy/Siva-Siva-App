Script "stack_surprise_card_id_1039"

/*
# Name: card "surprise_darshan" of stack "surprise"
# ID: card id 1039 of stack "surprise"
*/


on preopencard
   hide img "darshan"
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
   set the loc of image "darshan" to the loc of this card
   set the filename of img "darshan" to empty
  -- journal_addEntry
end closeCard

command getAnImage 
    showBusyIndicator true
      hide grp "go-next"
      put the long id of img "darshan" into tImgTarget
      hide img "darshan" with visual effect dissolve very fast
      put "Subramuniyaswami,Bodhinatha,Deities" into tCollections
      put item ( random(3) ) of tCollections into tCollection
      put fetchRandomMediaItem ("media_type","art/photography","tags",tCollection) into GotIt
      put getMediaURL ("med,whatever") into sURL
      set the filename of img "darshan" to sURL
      insertImageDimensions (the long ID of img "darshan")
      mediaUrl_Set sURL
      if the formattedwidth of tImgTarget > the width of this card then
         put "true" into tSizeIsBig
         toggleImgSize tImgTarget,tSizeIsBig,(the width of this card) 
      end if     
      showBusyIndicator false
      set the loc of img "darshan" to the loc of this card
      send showDarshan  to me in  20 milliseconds
end getAnImage

command showDarshan
   show img "darshan"  with visual effect reveal right very fast
   show grp "go-next"
end showDarshan

command share_Items 
   put mediaUrl_Get() into  sShareItemsA["url"]  
   put "Look at This!" into sShareItemsA["subject"]
   put "Darshan from SivaSiva app." into sShareItemsA["text"] 
   return sShareItemsA
end share_Items

-- on journal_AddEntry
--  put the short name of this card into pDataA["card"]
--    put "Darshan - God, Gods and Guru" into tJournalTitle
--    put mediaUrl_Get() into pDataA["url"]
--    Journal_RecordEntry "surprise", tJournalTitle, pDataA
-- end journal_AddEntry




