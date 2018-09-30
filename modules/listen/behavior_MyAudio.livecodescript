script "behavior_MyAudio" with behavior "behavior_ListenUI"

//> This script has parent behavior
//> behavior_ListenUI

//>LOCALS
local sDownloadedAudioA

on preopencard
    hide player "audioPlayer"
    put empty into fld  "currentTitleLabel"
    put "Listen Off Line" into fld "title-label"
    pass preopencard 
    # the handler the work of them mode indicator are there
    #  (the red underline showing you  what tab  you are in)
end preopencard

on openCard
   getDownloadedAudio
   if (fld "audioList" is empty) then
      doAnswer "You have not downloaded any audio", "OK","downloadAffirmed"
   end if
   
   audioIsRunning
  
end openCard

function getSelection pLine  
   return sDownloadedAudioA[pLine]
end getSelection

on passAudioSelection pLine,pTitle
   hide widget "turnOffAudio"
   startPlayer  sDownloadedAudioA[pLine][localURL],pTitle
   metadata_SetRecord (sDownloadedAudioA[pLine][metadata][1])
end passAudioSelection

on passAudioDetails sSelectNum,pTarget
     put the vis of fld "audioDetails" into detailVis
         if detailVis then
            deleteMobileControl "audioDetails"
            hide fld "audioDetails" with visual effect wipe down very fast
            send  "CreateScroller audioList" to fld "audioList"
         else
            select_ShowDetails  "downloaded",(sDownloadedAudioA[sSelectNum][metadata][1])
         end if
         set the flipped of widget pTarget to not detailVis
         break 
end passAudioDetails

command getDownloadedAudio
   local tList, tSearchA, tURL
   
   put empty into sDownloadedAudioA
   # do directory walk of the media/audio folder
   
   put (path_Documents() & "media/audio") into pFolder
   put listFilesWithPaths(pFolder, "true")  into tList
   repeat with x = 1 to (the number of lines of  tList)
      put line x of tList into tURL
      put tURl into sDownloadedAudioA[x][localURL]
      set the itemdel to "/"
      put item -2 of tURL into sDownloadedAudioA[x][file_id]
      repeat for each  line tKey in the keys of sDownloadedAudioA
         put sDownloadedAudioA[tKey][file_id]   into tSearchA["file_id"]
         put  fetchMediaItems(tSearchA) into  sDownloadedAudioA[tKey][metadata]
      end repeat
   end repeat
   
   # first look in the dates base
   
   repeat with x = 1 to (the number lines of keys of sDownloadedAudioA)
      if  sDownloadedAudioA[x][file_id] contains "-audiobook" then
         # get in from file names
         set the itemdel to "/"
         put  item -1 of sDownloadedAudioA[x][localURL] into aTitle
         put normalizeFileToTitle(aTitle) after sTitles
         put cr & cr after sTitles
         next repeat
      end if
      put sDownloadedAudioA[x][metadata][1]["title"] into aTitle
      
      if aTitle is empty then
         put sDownloadedAudioA[x][file_id] into aTitle
         put normalizeFileToTitle(aTitle) after sTitles
      else
         put aTitle after sTitles
      end if
      put cr after sTitles
      if sDownloadedAudioA[x][metadata][1]["media_type"] ="audio/song" then
         put sDownloadedAudioA[x][metadata][1]["artists"] after sTitles
      end if
      put cr after sTitles
      
   end repeat
   
   loadTitles sTitles
   
   # If file_id not into data base  register a message that the
   #  transcription/Lyrics  for this file is not available.
   
   #  get a URL locally for the files
   
   # If the metadata for the files  is available then the get from database
   
   #  ======
   
   # display titles and
end getDownloadedAudio


command loadtitles sTitles   
   hide fld "audioList"
   put sTitles into fld "audioList"
   typeSetAudioList
   show fld "audioList"
   put the number of lines of sTitles into pLineCount
end loadtitles

on closecard
   deleteAllMobileControls 
   clearPlayer # see the stack script
end closecard

#  ======
# Consider pre-loading datebase info for the recent talks
