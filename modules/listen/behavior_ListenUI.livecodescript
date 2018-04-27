script "behavior_ListenUI"
//>LOCALS
local sSelectNum, sSingleAudioA


on preopencard
   put empty into fld "CurrentTitleLabel"
end preopencard


on mouseUp

   put the short name of the target into pTarget
   switch pTarget
      case "collections-label"
         go to card "listen-collection"
         break
      case  "browse-label"
         go to card "listen-browse"
         break
      case "audioList"
         repeat with x=1 to (the number lines of fld "audioList")
            set the textcolor of line x of fld "audioList" to "251,240,200"
         end repeat
         put word 2 of clickline() into sSelectNum
         put sSelectNum into tLineNum
         if (tLineNum mod 2) = 0 then
            subtract 1 from tLineNum
         end if
         set the textcolor of line tLineNum of fld "audiolist" to "green"
         put line tLineNum fld "audioList" into pTitle
         put round(sSelectNum/2) into sSelectNum
         passAudioSelection sSelectNum, pTitle
         break
      case "chevron-up-down" # this is simple enough to do here
         put the vis of fld "audioDetails" into detailVis
         if detailVis then
            deleteMobileControl "audioDetails"
            hide fld "audioDetails" with visual effect wipe down very fast
            send  "CreateScroller audioList" to fld "audioList"
         else
            getAudioList
            select_ShowDetails (getDownloaded[sSelectNum])
         end if
         set the flipped of widget pTarget to not detailVis
         break
         
   end switch
end mouseUp


command getAudioList
   local tContext
   
   put the short name of this card into tContext
   switch tContext
      case "listen-browse"
         break
      case "listen-my-audio"
         put getSelection(sSelectNum) into  sSingleAudioA
         break
   end switch
end getAudioList


command startPlayer  sSelectedURL, pTitle
  
   --  local sSelectedURL, tRect
   
   if sSelectedURL contains "https" then # we need connectivity
      if connectivity_PingServer()<>"true" then
         dialog_CustomMsg "Offline or Low Bandwidth"
         exit startPlayer
      end if
   end if
   
   
   if isMobile() then
      if the platform is "android" then
         # the player is pretty ugly and covers up 120 vertical px
         # we need to try to get it to fit nicely at the bottom:
         put 70,625,350,659 into tRect    #90,630,340,675
      else
         put empty into tRect
      end if
      createMobileAudioPlayer sSelectedURL, "audioPlayer",tRect
   else
      set the filename of player "audioPlayer" to sSelectedURL
   end if
   
   showPlayer "true", "audioPlayer"
   if not isMobile() then
      start player "audioPlayer"
   else
      setMobileAudioPlayer "audioPlayer", "play"
   end if
   
   showBusyIndicator false
   put  pTitle into fld "currentTitleLabel"
   # Android player covers it! Because the controller higher that iOS one.
   if the platform is "Android" then
      set the bottom of fld "currentTitleLabel" to 600
   end if
   if there is a control "DownloadSelection" then
      set the vis of widget "DownloadSelection" to not (sSelectedItemA["cached"] )
   end if
end startPlayer


# V2 Link to transcript, we will have to show OFFLINE when the user come
# we have no functions to go back the internet for recents talks
# there the key "metadata" will be empty they return
# V2 which fetch data, installed in the data base


command select_ShowDetails 
   
   put the flipped of widget "chevron-up-down" into detailVis
   deleteMobileControl "audioList"
   put sSingleAudioA[metadata][1] into pRecord
   if pRecord <> empty then
      put getMediaItemMetadata(pRecord) into fld "audioDetails"
      set the textsize of line 1 of fld "audioDetails" to 22
      set the textstyle of line 1 of fld "audioDetails" to "bold"
      set the textstyle of line 3 of fld "audioDetails" to "italic"
      set the rect of fld "AudioDetails" to rect of fld "audioList"
      show fld "audioDetails" with visual effect wipe up very fast
      send "CreateScroller audioDetails" to fld "audioDetails"
   else
      doAnswer "Metadata is not available for recent talks you have downloaded.", "OK","downloadAffirmed"
      set the flipped of widget "chevron-up-down" to not detailVis
   end if
end select_ShowDetails
