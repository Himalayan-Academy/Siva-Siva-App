script "behavior_ListenUI"
//> Parent UI for several cards
-- on the Listen-Browser card.. is calling a player to an online audio
-- on My-Audio it calls a downloaded file on disk
-- the mouseup is trapped the card script of "listen-browse"

//>LOCALS
local sSelectNum, sSingleAudioA,sCached,sLineNum
local sAudioUI, sTimeStamp

on opencard
   audioIsRunning 
end opencard
  
  
on mouseUp
   local tTarget, tTitle
   ntinfo "Mouseup from behavior_Listen UI"
   --breakpoint
   put the short name of the target into tTarget
   
   switch tTarget
      case "collections-label"
         go to card "listen-collection"
         break
      case  "browse-label"
         go to card "listen-browse"
         break
      case  "my-audio-label"
         go to card "listen-my-audio"
         break
      case "audioList"
         --         if the short name of this card <> "listen-my-audio" then 
         --            offLineGoMyAudio
         --         end if
         if sLineNum <> empty then
            setAudioListColors sLineNum,"0,0,0"
         end if
         put word 2 of clickline() into sSelectNum
         
         put getLineNumber(sSelectNum) into sLineNum
         set the backgroundcolor of line sLineNum of fld "audiolist" to "174,30,66"
         
         put line sLineNum fld "audioList" into tTitle
         
         
         put round(sSelectNum/2) into sSelectNum
         # pass it back the cd script which has the main handlers
         --  breakpoint
         passAudioSelection sSelectNum, tTitle 
         break
         
         
      case "pauseAudio"
         if not isMobile() then
            put  the currentTime of player "audioPlayer" into sTimeStamp
         else
            put mobileControlGet ( "audioPlayer", "currentTime" ) into sTimeStamp
         end if
         pausePlayer sTimeStamp
         break
         
      case "playAudio"
         if not isMobile() then
            set  the currentTime of player "audioPlayer" to sTimeStamp
         end if
         playPausedAudio sTimeStamp
         break
         
      case "chevron-up-down" # this is simple enough to do here
         passAudioDetails sSelectNum,tTarget
         break
   end switch
end mouseUp



command switchAudioUi sAudioUI
   local pUI
   if sAudioUI is empty then
      put "hideUI" into sAudioUI
   end if
   # talks UI
   put empty into fld "searchString"
   put sAudioUI into pUI
   switch pUI
      case "hideUI"
         hide grp "titleDescription"
         hide grp "author"
         hide grp "songproperties"
         hide grp "searchControls"
         set the hilitedButton of group "collectionChoice" to empty
         break
      case  "Inspired Talks" 
         hide grp "songProperties"
         show grp "author" 
         set the top of grp "titleDescription" to 295
         show grp "titleDescription"   
         show grp "searchControls"
         break
         
         # song UI   
      case  "songs" 
         
         hide grp "author"
         set the top of  grp "titleDescription" to 157
         show grp "titleDescription"
         show grp "songProperties"
         set the hilited of btn "Title" to true -- group "titleDescription" to empty
         set the hilited of btn "Artists" to false
         show grp "searchControls"
   end switch
end switchAudioUi

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
   
   local  tRect, sSelectedItemA
   
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
   
   showPlayer "false", "audioPlayer"
   if not isMobile() then
      start player "audioPlayer"
      get runningAudioIndicatorVis("true")
   else
      setMobileAudioPlayer "audioPlayer", "play"
   end if
   put  pTitle into fld "currentTitleLabel"
   # Android player covers it! Because the controller higher that iOS one.
   if the platform is "Android" then
      set the bottom of fld "currentTitleLabel" to 600
   end if
   if there is a control "DownloadSelection" then
      set the vis of widget "DownloadSelection" to not (sSelectedItemA["cached"] )
   end if
   togglePause "true","true"
end startPlayer


command markCachedItems pKeys
   local pURL,tLocalStatus,tIsCached, sCurrentPlayListA
   repeat for each line x in pKeys
      # this as good a place as any to check for the existence of files  
      # and get the URL for every one in the play list... so we only do this once.
      put getItemURL(x) into pURL
      # Check and create folders here
      put path_isFileOnDisk(pURL) into tLocalStatus
      put item 1 of tLocalStatus into tIsCached
      put tIsCached into sCurrentPlayListA["audioFiles"][x]["cached"]
      if tIsCached then  # need to colored cached files on theUI
         # store line numbers
         put x & cr after sCached
         put item 2 of tLocalStatus into  sCurrentPlayListA["audioFiles"][x]["myURL"]
      else
         put pURL into sCurrentPlayListA["audioFiles"][x]["myURL"]
      end if
   end repeat
end markCachedItems
