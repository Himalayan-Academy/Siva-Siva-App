﻿script "behavior_ListenSelectPlay"

---------------------------------------------------------------------
# behavior_ListenSelectPlay
#
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
 
local sSelectionsA,sSelectedItemA

on preopencard
   hide player "audioPlayer"
end preopencard

on openCard
   # starts out with the entire play list unfiltered
   # card should already have the list installed after stack opens
   # pass sCurrentPlayListA from stack to card:  
   playlist_Reset 
   
end openCard



on playlist_SetSelections pFilter
   # begins with the entire array of the playlist
   put playlist_GetRecords() into sSelectionsA 
   if pFilter is empty then
      # do nothing... an offer filters later
   else
      # do some filtering of current play list in V2
   end if
end playlist_SetSelections

# if a filter ran, we can get the whole list back:
on playlist_Reset
   put playlist_GetRecords() into sSelectionsA 
end playlist_Reset

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
         select_Play  clickline()
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

on select_Play  pSelectedLine
   playlist_Reset # needed during dev because we often lose the sSelectedItemA value
   lock screen
   resetLines 
   set the foregroundcolor of  pSelectedLIne to green
   unlock screen
   put word 2 of pSelectedLIne into tSelectNum
   
   # send of to lib_SivaSivaMedia, which knows all about our media CMS
   # but Audio books are completely different CMS: they have no item records for their audio files
   
   if (sSelectionsA["playlistClass"] = "latest")  OR (sSelectionsA["playlistClass"] ="cached") then
      # everything happens via Jnanam table structure record array
      put sSelectionsA["audioFiles"][tSelectNum] into sSelectedItemA
      metadata_SetRecord sSelectedItemA   
      put getMediaURL (sSelectedItemA["item_id"]) into tURL
      
      # but lib_SivaSivaMedia won't have string for the latest item
      # fortunately there is easily solution for audio:
      if char -1 of tURL = "/" then
         put sSelectedItemA["file_id"] & ".mp3" after tURL
      end if      
   else
      # its an audio book
      put getMediaURL("audioBook") into tURL
      put sSelectionsA["audioBookMetadata"][1]["file_id"] & "/" after tURL
      put sSelectionsA["audioFiles"]["toc"][tSelectNum]["file"] after tURL
   end if
   
   if tURL = "" then -- jg: don't continue
      put "Media not found" into fld "audioDetails"
      set the height of fld "audioDetails" to the formattedHeight of fld "audioDetails"
      send mouseUp to widget "chevron-up-down"
      showBusyIndicator false
      exit to top
   end if
   
   
   if isMobile() then
      if the platform is "android" then 
         # the player is pretty ugly and covers up 120 vertical px
         # we need to try to get it to fit nicely at the bottom:
         put 70,570,405,679 into tRect

      else 
         put empty into tRect
      end if     
      createMobileAudioPlayer tURL, "audioPlayer",tRect
   else
      set the filename of player "audioPlayer" to tURL
   end if
   
   showPlayer "true", "audioPlayer"
   if not isMobile() then 
      start player "audioPlayer"
   else
      setMobileAudioPlayer "play"
   end if
   showBusyIndicator false
   put  sSelectedItemA["title"] into fld "currentTitleLabel"
 Journal_AddEntry pSelectedLIne
end select_Play


# V2 Link to transcript

command select_ShowDetails   
   deleteMobileControl "audioList"
    if (sSelectionsA["playlistClass"] = "latest")  OR (sSelectionsA["playlistClass"] ="cached") then
       put textDecode (getMediaItemMetadata(),"UTF8") into  fld "audioDetails"  
    else
       # its an audio book, lib media doesn't know anything, we have to pass the record here       
     put  getMediaItemMetadata(sSelectionsA["audioBookMetadata"][1]) into fld "audioDetails"
   end if
  
   set the textsize of line 1 of fld "audioDetails" to 22
   set the textstyle of line 1 of fld "audioDetails" to "bold"
   set the textstyle of line 3 of fld "audioDetails" to "italic"
   set the rect of fld "AudioDetails" to (0,the bottom of fld "title",the width of this card,the height of this card -150) 
   show fld "audioDetails" with visual effect wipe up very fast
   send "CreateScroller audioDetails" to fld "audioDetails"
end select_ShowDetails

# we should create a global library for all things text and just pass params
# for now: 

on resetLines
       set the hilitedlines of fld "audioList" to 0
   repeat with x = 1 to the number of lines of fld "audioList"
      set the foregroundcolor of line x of  fld "audioList" to 251,240,200
   end repeat
end resetLines

on Journal_AddEntry pSelectedLine
   put  sSelectionsA["playlistTitle"] into tPlayList
   put tPlayList into pData["playlist"]
   put "listen-playlist" into pDataA["card"]
   put pSelectedLine into pDataA["playSelection"]
   put value(pSelectedLine) into tPlayFileLabel
   put (char 1 to 15 of tPlayFileLabel)  & "..."  into tPlayFileLabel
   Journal_RecordEntry "listen",( tPlayList &": " & tPlayFileLabel), pDataA
end Journal_AddEntry


on cleanUpGUI
   # more later but for now, so no flash of previous content 
   put empty into fld "title" of this card
   set the filename of img "playlistPoster" of this card to empty
   put empty into fld "audioList" of this card
   put empty into fld "currentTitleLabel" of this card
   set the filename of player "audioPlayer"  of this card to empty
   hide fld "audioDetails" of this card
   put empty into fld "audioDetails" of this card
   showPlayer "false", "audioPlayer" 
   ## add other mobile stuff to clear out here later
end cleanUpGUI

on closeCard
   set the acceleratedrendering of this stack to false
   showPlayer "false","audioPlayer"
   if isMobile() then 
      deleteAllMobileControls
   end if
end closeCard

-- on closeStack
--    cleanUpGUI
-- end closeStack
