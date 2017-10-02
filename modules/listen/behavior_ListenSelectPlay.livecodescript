script "behavior_ListenSelectPlay"

---------------------------------------------------------------------
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

local sSelectionsA,sSelectedItemA,sSelectedURL,sRemoteURL,sSelectNum,sLastTarget

on preopencard
   hide player "audioPlayer"
end preopencard

on openCard
   # starts out with the entire play list unfiltered
   # card should already have the list installed after stack opens
   # pass sCurrentPlayListA from stack to card:  
   playlist_Reset 
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
      case "AudioList"
           put word 2 of clickline() into sSelectNum
         select_Play # will use either the line number or item id
         break  
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
      case "revealMoreActions"
         put not (the vis of grp "moreActions") into pVis
         revealMoreActions pVis
         break
   end switch
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
      playlist_Reset # needed during dev because we often lose the sSelectedItemA value
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
      send mouseUp to widget "chevron-up-down"
      showBusyIndicator false
      exit to top
   end if
   startPlayer
   Journal_AddEntry  sSelectedItemA["item_id"]
   put "audiotitle="& sSelectedItemA["title"]   into pTrackdata["contentTarget"]
   tracking_RecordActivity "Surprise", "navigation/playaudio", pTrackdata
end select_Play

command startPlayer pURL, pTitle
   
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
         put 70,570,405,679 into tRect       
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
   put  sSelectedItemA["title"] into fld "currentTitleLabel"
   # put  sSelectionsA["audioFiles"][sSelectNum]["title"] into fld "currentTitleLabel"
   # Android player covers it!
   if the platform is "Android" then
      set the bottomleft of widget "downloadSelection" to 14,657
   else
      set the bottom of widget "downloadSelection" to 622
   end if
   set the vis of widget "DownloadSelection" to not (sSelectedItemA["cached"] )
   #set the vis of widget "DownloadSelection" to not (sSelectionsA["audioFiles"][sSelectNum]["cached"] )
end startPlayer


# V2 Link to transcript

command select_ShowDetails   
   deleteMobileControl "audioList"
   if (sSelectionsA["playlistClass"] = "latest")  OR (sSelectionsA["playlistClass"] ="cached") then
      put getMediaItemMetadata() into fld "audioDetails"
   else
      # its an audio book, lib media doesn't know anything, we have to pass the record here       
      put  getMediaItemMetadata(sSelectionsA["audioBookMetadata"][1]) into  fld "audioDetails"     
   end if
   
   set the textsize of line 1 of fld "audioDetails" to 22
   set the textstyle of line 1 of fld "audioDetails" to "bold"
   set the textstyle of line 3 of fld "audioDetails" to "italic"
   set the rect of fld "AudioDetails" to (0,the bottom of fld "title",the width of this card,the height of this card -150) 
   show fld "audioDetails" with visual effect wipe up very fast
   send "CreateScroller audioDetails" to fld "audioDetails"
end select_ShowDetails

command revealMoreActions pVis
   
   
   --pVis = boolean
   
   if there is no grp "moreActions" then -- unplaced on current cd; just set vis & exit
      set the vis of bg "moreActions" to pVis
      exit revealMoreActions
   end if 
   if  pVis <> false  then -- show it
      set the acceleratedRendering of this stack to false
      
      set the hilitedbuttonName of grp "deity" to "All"
      set the hilitedbuttonName of grp "genre" to "All"
      set the hilitedbuttonName of grp "textColumns" to empty
      --jg: horiz centering for mobile screens:
      set the loc of grp "moreActions" to the loc of this cd
      set the bottom of grp "moreActions" to 0
      put empty into fld "searchString" of grp "moreActions"
      # Set up the form ahead of time
      # we hide everything not needed for talks
      if sSelectionsA["playListTitle"] contains "Talks" then
         hide grp "songProperties"
         hide button "artists" of grp "textColumns"
         show button "Subtitle" of grp "textColumns"
      end if
      if sSelectionsA["playListTitle"] = "Songs" then
         show grp "songProperties" 
         hide button "Subtitle" of grp "textColumns"
         show button "Artists" of grp "textColumns"
      end if
      set the vis of group "moreActions" to true
      moveGrp "moreActions", 0, the height of grp "moreActions", 500
      put "Leave All Empty to Reset" into fld "searchString"
      wait 1 second; put empty into fld "searchString"
      focus on fld "searchString" --jg: force mobile keyboard
      select after fld "searchString"
   else -- hide it
      set the acceleratedRendering of this stack to true
      focus on nothing
      moveGrp "moreActions", 0, -(the height of grp "moreActions"), 500
      hide group "moreActions"
      put empty into fld "searchString"
   end if  
   
end revealMoreActions


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

command updateCachedListings 

   put "true" into sSelectionsA["audioFiles"][sSelectNum]["cached"]
   set the foregroundcolor of line sSelectNum of fld "audioList" to green
   # Later we need to update the myURL of the play list selection.
   # but for now we assume if they have enough bandwidth to download
   # let them stream... when they come back later the list will be updated
   
   
end updateCachedListings


on cleanUpGUI
   # more later but for now, so no flash of previous content 
   put empty into fld "title" of this card
   set the filename of img "playlistPoster" of this card to empty
   put empty into fld "audioList" of this card
   put empty into fld "currentTitleLabel" of this card
   set the filename of player "audioPlayer"  of this card to empty
   hide fld "audioDetails" of this card
   hide widget "revealMoreActions"
   hide widget "downloadSelection"
   put empty into fld "audioDetails" of this card
   showPlayer "false", "audioPlayer" 
   ## add other mobile stuff to clear out here later
end cleanUpGUI

on closeCard
   showPlayer "false","audioPlayer"
end closeCard



