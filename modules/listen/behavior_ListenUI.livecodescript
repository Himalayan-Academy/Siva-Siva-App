script "behavior_ListenUI"

passAudioSelection//>LOCALS
local sSelectNum, sSingleAudioA,sCached,sLineNum
local sAudioUI

on opencard
   audioIsRunning
end opencard
  
  
  on mouseUp
   put the short name of the target into pTarget
   switch pTarget
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
         if sLineNum <> empty then
            set the backgroundcolor of line sLineNum of fld "audioList" to empty
        end if
         put word 2 of clickline() into sSelectNum
         put sSelectNum into sLineNum
         if (sLineNum mod 2) = 0 then
            subtract 1 from sLineNum
         end if
         set the backgroundcolor of line sLineNum of fld "audioList" to 176,30,66
         put line sLineNum fld "audioList" into pTitle
         put round(sSelectNum/2) into sSelectNum
         passAudioSelection sSelectNum, pTitle
         break
      case "chevron-up-down" # this is simple enough to do here
         passAudioDetails sSelectNum,pTarget
         break
         
   end switch
end mouseUp



command switchAudioUi sAudioUI
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
   
   --  local sSelectedURL, tRect
   
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
end startPlayer


command markCachedItems pKeys
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
