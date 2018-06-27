script "behavior_ListenSelectPlay" with behavior "behavior_ListenUI"

-----------------------------
# This behavior has a parent behavior "behavior_ListenUI"
-----------------------------
# behavior_ListenSelectPlay
# Assigned to card "listen-playlist" of stack "Listen"

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
local sSelectionsA,sSelectedItemA,sSelectedURL,sRemoteURL,sSelectNum,sLastTarget

on preopencard
   hide player "audioPlayer"
   pass preopencard
end preopencard

on openCard
   # starts out with the entire play list unfiltered
   # card should already have the list installed after stack opens
   # pass sCurrentPlayListA from stack to card:  
   -- set GUI
   put empty  into fld "currentTitleLabel"
   playlist_Reset 
   audioIsRunning
end openCard


on playlist_SetSelections pFilteredPlayList
   # begins with the entire array of the playlist 
end playlist_SetSelections

on playlist_Reset
   put playlist_GetRecords() into sSelectionsA   
end playlist_Reset

function checkPlayList
   return the keys of sSelectionsA
end checkPlayList


-----------------------------------------------------------------------
# UI Interactions | card, group, list, detail display change ups
-----------------------------------------------------------------------

on mouseup
   --answer "hello" with "OK"
   # there are no scripts at all ( or should not be unless really needed)
   #  in any objects of the UI.
   # all logic for user interaction with the GUI is handled here.
   # but please don't overload the case statements
   # this just a mouse/touch event router. 
   # encapsulate discreet actions that take more than a few lines
   # to separate handlers.
   
   put the target into pTarget
   put the short name of the Target  into tTarget   
   
   switch tTarget
      # card navigaton
      case "collections-label"
         go to card "listen-collection"
         break
      case "my-audio-label"
         go to card "listen-my-audio"
         break
      case "AudioList"
         stopPlayer # make sure previous player, if there is one, is deleted.
         clearPlayer # in parent Listen_UI
         setAudioListColors
         put word 2 of clickline() into sSelectNum
         put sSelectNum into tLineNum
         if (tLineNum mod 2) = 0 then
            subtract 1 from tLineNum
         end if
         set the backgroundcolor of line tLineNum of fld "audiolist" to "174,30,66"
         put round(sSelectNum/2) into sSelectNum      
         select_Play # will use either the line number or item id
         break  
         
         # this if for showing lyric, artist or transcript
         # add appears in 
      case "chevron-up-down" # this is simple enough to do here
         put the vis of fld "audioDetails" into detailVis
         if detailVis then
            deleteMobileControl "audioDetails"
            hide fld "audioDetails" with visual effect wipe down very fast
            send  "CreateScroller audioList" to fld "audioList"
         else
            select_ShowDetails 
         end if
         set the flipped of pTarget to not detailVis
         break
      case "DownloadSelection" 
         if connectivity_PingServer() <> "true" then
            dialog_CustomMsg "Offline or Low Bandwidth"
            exit mouseup
         end if
         downloadSelection pTarget
         break
   end switch
   
   -- there a mouseup on the parent behavior also, if you need to use it: 
   -- pass mouseUp   
   
end mouseup

---------------------------------------------
# Select, Play, Listen, Stop UI interactions
---------------------------------------------

---------------------------------------------
# Select_Play
#
# DESCRIPTION: Only two jobs here
#     - show the title
#     - set the URL for the player
#    -  do the necessary for the mobile player
#     - start the player
# we should move common handlers off to a global  lib (may have them already)
# because we are going to be doing audio all over the app,
# not just here.
# 
# PARAMS: The selected line get the array element
# and away we go
#
# CHANGES: 2017-06-22, CREATED Brahmanathswami
---------------------------------------------

on select_Play  pitemID  # if item id is empty then defaults to the click line number
   
   # if we are coming from a click on the card list then the pItemID will be empty
   # but we may be dropping in from the journal or another type of list that
   # simple passes the item_id for the record.. and there is no pSelectedLIne
   
   if pItemID is empty then # search from the click line
      put getItemURL(sSelectNum) into sRemoteURL
      Put "Connecting..." into fld "currentTitleLabel"
 --   playlist_Reset # needed during dev because we often lose the sSelectedItemA value
      put sSelectionsA["audioFiles"][sSelectNum] into sSelectedItemA   
      metadata_SetRecord sSelectedItemA
      put sSelectionsA["audioFiles"][sSelectNum]["myURL"] into sSelectedURL
   else
      put pitemID into tSearchA["item_id"]
      put  fetchMediaItems(tSearchA) into tTargetRecordA # returns only 1 record
      put tTargetRecordA[1] into sSelectedItemA
      metadata_SetRecord sSelectedItemA
      put getMediaURL() into sSelectedURL
      put path_isFileOnDisk(sSelectedURL) into tLocalStatus
   end if
   
   # Lyrics fetch is a separate function, see lib_SivaSiva Meida
   
   get getSongLyrics(sSelectedItemA["item_id"])
   
   if sSelectedURL = "" then -- jg: don't continue
      put "Media not found" into fld "audioDetails"
      set the height of fld "audioDetails" to the formattedHeight of fld "audioDetails"
      showBusyIndicator false
      exit to top
   end if
   startPlayer sSelectedURL, sSelectedItemA["title"]  #see nested behavior_ListenUI
   Journal_AddEntry  sSelectedItemA["item_id"]
   put "audiotitle="& sSelectedItemA["title"]   into pTrackdata["contentTarget"]
   tracking_RecordActivity "Surprise", "navigation/playaudio", pTrackdata
end select_Play

--------------

command downloadSelection pTarget
   put the long ID of pTarget into sLastTarget
   doAnswer "Download this audio file?", "Download,Cancel","downloadAffirmed"
end downloadSelection

command downloadAffirmed   
   if sSelectionsA["playListClass"] ="audiobook" then
      put sSelectionsA["audioFiles"]["toc"][sSelectNum]["label"] into pTitle
   else
      put  sSelectionsA["audioFiles"][sSelectNum]["title"]  into pTitle
   end if
   put "listen" into sConfigA[last_stack]
   hide stack "listen"
   go stack "view_Download"
   dispatch "downloadURL"  to stack "view_Download" with  pTitle,sSelectedURL,sSelectNum,sLastTarget
end downloadAffirmed

on Journal_AddEntry pItemID
   put  sSelectionsA["playlistTitle"] into tPlayList
   put tPlayList into pDataA["playlist"]
   put "listen-playlist" into pDataA["card"]
   put pItemID into pDataA["item_id"]
   put sSelectedItemA["title"] into pDataA["playSelection"]
   put sSelectedURL into pDataA["audioURL"]
   put  sSelectedItemA["title"] into tPlayFileLabel
   put (char 1 to 15 of tPlayFileLabel)  & "..."  into tPlayFileLabel
   Journal_RecordEntry "listen",( tPlayList &": " & tPlayFileLabel), pDataA
end Journal_AddEntry

command share_Items 
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
   showPlayer "false","audioPlayer"
    deleteAllMobileControls 
end closeCard

command select_ShowDetails   pSelectSong
   deleteMobileControl "audioList"
   if (sSelectionsA["playlistClass"] = "latest")  OR (sSelectionsA["playlistClass"] ="cached") then
      put getMediaItemMetadata() into jai
      put jai into fld "audioDetails"
   else
      # its an audio book, lib media doesn't know anything, we have to pass the record here       
      put  getMediaItemMetadata(sSelectionsA["audioBookMetadata"][1]) into  fld "audioDetails"     
   end if   
   set the textsize of line 1 of fld "audioDetails" to 22
   set the textstyle of line 1 of fld "audioDetails" to "bold"
   set the textstyle of line 3 of fld "audioDetails" to "italic"
   set the rect of fld "AudioDetails" to rect of fld "audioList" 
   show fld "audioDetails" with visual effect wipe up very fast
   send "CreateScroller audioDetails" to fld "audioDetails"
end select_ShowDetails




