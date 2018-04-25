script "behavior_ListenUI"
on preopencard
   put empty into fld "CurrentTitleLabel"   
end preopencard

on mouseUp 
   put the short name of the target into tTarget
   switch tTarget
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
         
         
         --          repeat with x=1 to (the number lines of fld "audioList")
         --             set the textcolor of line x of fld "audioList" to "white"
         --          end repeat
         --          put word 2 of clickline() into sSelectNum
         --          set the textcolor of line sSelectNum of fld "audiolist" to "green"
         --          put value(the clickline) into pTitle
         --          passAudioSelection sSelectNum, pTitle
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
