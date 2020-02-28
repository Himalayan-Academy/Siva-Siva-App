script "behavior_MyAudio" with behavior "behavior_ListenUI"

//> This script has parent behavior
//> behavior_ListenUI

-- there is no mouseup here but in the behavior_ListenUI
-- Which calls handlers here when it in on this card

//>LOCALS
local sDownloadedAudioA

on preopencard
   updateUI
   pass preopencard 
   # the handler the work of them mode indicator are there
   #  (the red underline showing you  what tab  you are in)
end preopencard

on openCard
   getDownloadedAudio
   
   if (fld "audioList" is empty) then
      dialog_CustomMsg "You have not downloaded any audio"
   end if
   
   audioIsRunning
   

   
end openCard

command doAnswerAffirmed
   hide grp "AnswerDlgGrp"
end doAnswerAffirmed



function getSelection pLine  
   return sDownloadedAudioA[pLine]
end getSelection

on passAudioSelection pLine,pTitle
   
   hide widget "turnOffAudio"
   startPlayer  sDownloadedAudioA[pLine]["localURL"],pTitle
   
   # try to solve the problem of no controller in iOS 13.1.3
   # We just let use pause or continue audio
   # no scrubbing  forward or back
   # this may be a better UI on the long run... 
   # see Audible and Book App -AudioBooks for a standard model.
   togglePause true, true
   
   metadata_SetRecord (sDownloadedAudioA[pLine][metadata][1])

end passAudioSelection



on passAudioDetails sSelectNum,pTarget
   local tDetailVis
   put the vis of fld "audioDetails" into tDetailVis
   if tDetailVis then
      deleteMobileControl "audioDetails"
      hide fld "audioDetails" with visual effect" wipe down" very fast
      send  "CreateScroller audioList" to fld "audioList"
   else
      select_ShowDetails  "downloaded",(sDownloadedAudioA[sSelectNum][metadata][1])
   end if
   
   set the flipped of widget pTarget to not tDetailVis
   break 
end passAudioDetails

--command getDownloadedAudio
--   local tList, tSearchA, tURL,pFolder,tTitle,tTitles

--   put empty into sDownloadedAudioA
--   # do directory walk of the media/audio folder

--   put (path_Documents() & "media/audio") into pFolder
--   put listFilesWithPaths(pFolder, "true")  into tList
--   repeat with x = 1 to (the number of lines of  tList)
--      put line x of tList into tURL
--      put tURL into sDownloadedAudioA[x]["localURL"]
--      set the itemdel to "/"
--      put item -2 of tURL into sDownloadedAudioA[x]["file_id"]
--      repeat for each  line tKey in the keys of sDownloadedAudioA
--         put sDownloadedAudioA[tKey]["file_id"]   into tSearchA["file_id"]
--         put  fetchMediaItems(tSearchA) into  sDownloadedAudioA[tKey][metadata]
--      end repeat
--   end repeat

--   # first look in the dates base

--   repeat with x = 1 to (the number lines of keys of sDownloadedAudioA)
--      if  sDownloadedAudioA[x]["file_id"] contains "-audiobook" then
--         # get in from file names
--         set the itemdel to "/"
--         put  item -1 of sDownloadedAudioA[x]["localURL"] into tTitle
--         put normalizeFileToTitle(tTitle) after tTitles
--         put cr & cr after tTitles
--         next repeat
--      end if
--      put sDownloadedAudioA[x][metadata][1]["title"] into tTitle

--      if tTitle is empty then
--         put sDownloadedAudioA[x]["file_id"] into tTitle
--         put normalizeFileToTitle(tTitle) after tTitles
--      else
--         put tTitle after tTitles
--      end if
--      put cr after tTitles
--      if sDownloadedAudioA[x][metadata][1]["media_type"] ="audio/song" then
--         put sDownloadedAudioA[x][metadata][1]["artists"] after tTitles
--      end if
--      put cr after tTitles

--   end repeat

--   loadTitles tTitles

--   # If file_id not into data base  register a message that the
--   #  transcription/Lyrics  for this file is not available.

--   #  get a URL locally for the files

--   # If the metadata for the files  is available then the get from database

--   #  ======

--   # display titles and
--end getDownloadedAudio




command updateUI
   local pControl
   # standard handle for responsive formatting 
   # and other things related to the position and state of the UI
   # this card
   
   hide player "audioPlayer"
   put "Listen Off Line" into fld "title-label"
   put empty  into fld "currentTitleLabel"
   put the long id of group "pause-play" into pControl
   set the loc of pControl to horizCenter(), (the bottom of widget "chevron-up-down" of me +30 ) 
   togglePause false, true
end updateUI

on closecard
   deleteAllMobileControls 
   clearPlayer # see the stack script
end closecard

#  ======
# Consider pre-loading datebase info for the recent talks
