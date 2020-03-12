script "behavior_ListenSelectPlay"
# behavior_ListenSelectPlay
# Assigned to card "listen-Browse" of stack "Listen"

# DESCRIPTION: This script handles all interaction with a previously instantiated playlist
# user selections of audio, display of info etc are triggered here in this script.
#
#  PARAMS: We need the sCurrentPlayListA array
# which contains the necessary records
# use playlist_GetRecords() which is in the stack script
# theoretically the playlist/array is already instantiated
#
# CHANGES: 2017-06-22 created, Brahmanathaswami
#
---------------------------------------------------------------------
# Devtools: control click on the image to show devtools group  and hide it
# add more if you like.. there is a field  "localResult" you can use instead
# of the msg box... helpful at times...
---------------------------------------------------------------------
global sConfigA
local sSelectedItemA,sSelectedURL,sRemoteURL,sSelectNum,sLastTarget,sLineNum
local sTimeStamp, sSelectionsA, sDownloadedAudioA,sCardName


on openCard
   local tCardName
   put the short name of this card into sCardName
   
   switch sCardName
      case "listen-my-audio"
         getDownloadedAudio 
         put the result into sDownloadedAudioA
         
         if (fld "audioList" is empty) then
            dialog_CustomMsg "You have not downloaded any audio"
         end if
         break
      case "listen-browse"
         clearSelection
         break
      case "listen-file"
         clearSelection
         put empty  into fld "currentTitleLabel"
         put   empty into  fld "audio-details"
         break 
   end switch
   
   playlist_Reset 
   audioIsRunning
   if the logMessage <> empty then
      copyLogControl
   end if
   
end openCard



-----------------------------------------------------------------------
# UI Interactions | card, group, list, detail display change ups
-----------------------------------------------------------------------

on mouseup
   local pTarget, tTarget, detailVis
   -- answer "hello" with "OK"
   # there are no scripts at all ( or should not be unless really needed)
   #  in any objects of the UI.
   # all logic for user interaction with the GUI is handled here.
   # but please don't overload the case statements
   # this just a mouse/touch event router. 
   # encapsulate discreet actions that take more than a few lines
   # to separate handlers.
   
   put long id of the target into pTarget
   put the short name of the Target  into tTarget   
   --breakpoint
   switch tTarget
      # card navigaton
      case "collections-label"
         go to card "listen-collection"
         break
      case "my-audio-label"
         go to card "listen-my-audio"
         break
      case "AudioList"
         local tTitle,localURL
         # sLineNum is the physical line number the user clicks on the field
         # sRecentNum is the numeric key value is the sSelectionsA play list array
         
         hide widget "turnOffAudio"
         stopPlayer # make sure previous player, if there is one, is deleted.
         clearPlayer # in parent Listen_UI
         
         # clear the color of the last line before setting the  sLineNum
         if sLineNum <> empty then
            setAudioListColors sLineNum,"0,0,0"
         end if
         
         # now we register the user interaction: clicks on a line.
         
         put word 2 of clickline() into sLineNum
         
         # every 2 line is one entry; we just one to color the Title
         # though the use might click on the artist...
         
         if (sLineNum mod 2) = 0 then
            subtract 1 from sLineNum
         end if
         put line sLineNum of fld "audiolist" into tTitle
         set the backgroundcolor of line sLineNum of fld "audiolist" to "174,30,66"
         
         # the follow "trick" return the array key
         put round(sLineNum/2) into sSelectNum 
         
         # if the use had downloaded audio it appears on my-audio card
         # we can start the player; get the audio locally:\
         if sCardName = "listen-my-audio" then 
            --command startPlayer  pURL, pTitle,sCardName,sSelectNum
            startPlayer  "",tTitle,sCardName,sSelectNum
         else
            select_Play sSelectNum,,sCardName  # will use either the line number or item id
         end if
         break  
         
         # this if for showing lyric, artist or transcript
         # add appears iinterrupt()
         # it have pass sTimeStamp before you touch the player
         
      case "pauseAudio"
         if not isMobile() then
            put  the currentTime of player "audioPlayer" into sTimeStamp
         else
            put mobileControlGet ( "audioPlayer", "currentTime" ) into sTimeStamp
         end if
         
         pausePlayer sTimeStamp
         break
         
      case "playAudio"
         --breakpoint
         --  ntInfo sTimeStamp
         if not isMobile() then
            set  the currentTime of player "audioPlayer" to sTimeStamp
         end if
         playPausedAudio sTimeStamp
         break
         
      case "chevron-up-down" # this is simple enough to do here
         local tSelection,tRecord
         put the vis of fld "audioDetails" into detailVis
         set the flipped of pTarget to detailVis
         if detailVis then
            deleteMobileControl "audioDetails"
            hide fld "audioDetails" with visual effect "wipe down" very fast
            send  "CreateScroller audioList" to fld "audioList"
         else
            if sCardName = "listen-my-audio" then
               put "downloaded" into tSelection
               put sDownloadedAudioA[sSelectNum][metadata][1] into tRecord
            end if 
            select_ShowDetails tSelection,tRecord
         end if
         set the flipped of pTarget to not detailVis
         break
      case "DownloadSelection" 
         if connectivity_PingServer() <> "true" then
            dialog_CustomMsg "Offline or Low Bandwidth"
            exit mouseup
         end if
         portal_SetLastStack "Listen"
         
         downloadSelection sSelectNum, pTarget
         break
      case "Loading"
         showBusyIndicator false
         stopPlayer
         break
   end switch
   
   
end mouseup


command share_Items 
   local tURL,  sShareItemsA
   if sRemoteURL is empty then
      put "https://www.himalayanacademy.com/view/sivasiva" into  tURL
   else
      put sRemoteURL into tURL
   end if
   put tURL into  sShareItemsA["url"]  
   put "Listen to This!" into sShareItemsA["subject"]
   put "Audio available in the SivaSiva app." into sShareItemsA["text"] 
   return sShareItemsA
end share_Items

on closeCard
   clearAudioListColor
   showPlayer "false","audioPlayer"
   deleteAllMobileControls 
   put empty into sLineNum
end closeCard


