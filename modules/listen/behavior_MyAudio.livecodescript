script "behavior_MyAudio"
local sDownloadedAudioA


on preopencard

end preopencard

on openCard
   getDownloadedAudio
end openCard

command getDownloadedAudio
   hide fld "audioList"
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
      put sDownloadedAudioA[x][metadata][1]["title"] into aTitle
      if aTitle is empty then 
         put sDownloadedAudioA[x][file_id] after sTitles
      else 
         put aTitle after sTitles
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

   put sTitles into fld "audioList"  
   put the number of lines of sTitles into pLineCount
   addSpaceBelowListLines (the long id of fld "audioList"), pLineCount, 10
   show fld "audioList"
end loadtitles

#  ======

# Consider pre-loading datebase info for the recent talks





