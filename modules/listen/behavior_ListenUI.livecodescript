script "behavior_ListenUI"

on mouseUp 
   put the target into pTarget
   put the short name of the Target  into tTarget   
   
   switch tTarget
      case "collections-label"
         go to card "listen-collection"
         break
      case  "browse-label"
         go to card "listen-browse"
         break
      case "audioList"
         put word 2 of clickline() into sSelectNum
         put value(the clickline) into pTitle
          passAudioSelection(sSelectNum, pTitle)
         break
   end switch
end mouseUp

command startPlayer  sSelectedURL, pTitle
   
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
         put 70,625,350,659 into tRect       
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
