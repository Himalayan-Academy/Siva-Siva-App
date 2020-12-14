script "behavior_Download"
/* behavior_Download

DESCRIPTION: 
This behavior is used in V1 for the stack view_Download.livecode stack
But we are coding this so that it could be attached to any card with the necessary
UI controls, so it could be used anywhere later.
It's also less trouble dealing with the UI updates if it is a behavior and not a backscript.

Basic functional spec:
1) Each module is responsible to check for the existence of a file 
that is may need. See the lib_SivaSiva  functions:
path_IsFileOnDisk
and 
path_FileForUrl  # will creae a folder if needed for the request URL

2) There is a downloads button on some card on some 
3) Each developer is reponsible to check for existence of a file/URL 
4) if false, expose the download button on the card in the context of that module's UX/UI
5) the download widget/button (at least in V1 )opens the view_Download Livecode stack
6) We store the target so we know which was the stack that initiated the download.
7) and then initiates the download with that interface up and responding to call backs.
8) use should have the option to cancel out and close the view_Download stack
9) Call back on the urlStatus updates are fed to the download view.
10) when complete/error/timeout/cancelled we dispatch this info to the stack that was the target
12) which responds as per the module requirements
*/

--------------------------------
-- Taken from LiveCode on line lessons, 

-------------------------------
-- vars
global sConfigA
local sURL, sRequestedBy, sRecordNumber, sDownloadStart

---------------------------------
-- downLoadURL
-- DESCRIPTION: fetches data from remote server and saves it
-- updates UI on progress, errors, timeout and success
-- PARAMS
-- requesting module must pass 
-- pTitle : user friendly human readable label for the item being downloaded
-- pURL: absolute, fully qualified https url)
-- pLocalFilePath:  this is a path relative to the app's writable documents
--      folder; this is worked out by path functions in lib_SivaSiva
--     and not handled here,the calling handlers check for the presence of files
--    and the module developer has to decide to automatically
--   download or ask the user etc. this behavior does not know the use case
-- and assumes the answer to "do you want to download" is already "yes"
-- otherwise it is not even called in the first place.


on downLoadURL pTitle,pURL,pRecordNumber,pRequestedBy
   
   put pTitle into fld "progressTitle"
   
   # store some info in local so we can use these when we send msg
   # back to the calling stack.
   
   put pURL into sURL 
   put pRecordNumber into sRecordNumber
   put pRequestedBy into sRequestedBy
   
   -- set up a message to show the status of the download as it progresses
   libURLSetStatusCallback "showProgress", the long name of grp "downloadControls"
   	
   -- make sure the progress bar is hidden, as this property is used to initialise it
   hide scrollbar "ProgressBar"
   put "Waiting for connection"  into fld "ProgressField"
   put the seconds into sDownloadStart
   	
   -- start the download process, telling Rev to call the "downloadComplete" handler when finished
   load URL pURL with message "downloadComplete"
end downLoadURL


command showProgress pURL, pStatus
   -- this is the status callback message which gets called regularly during the download
   -- pStatus will show some initialisation messages, then
   -- loading,bytesReceived,bytesTotal
   	
   -- using a graphical progress bar instead
   -- ths first time this is called, find the total number of bytes that are to be downloaded
   -- use this info to set the span of the progress bar
   	
   -- wait until the download info is being received
   
   local tTotalBytes, tBytesReceived, tKBreceived, tTotalKB, tElapsedSeconds
   local tKBperSecond,
   
   
   
   if the number of items in pStatus = 3 then
      if the visible of scrollbar "Progressbar" = false then
         put the last item of pStatus into tTotalBytes
         set the startValue of scrollbar "Progressbar" to 0
         set the endValue of scrollbar "Progressbar" to tTotalBytes
         show scrollbar "Progressbar"
      end if
      
      set the thumbPosition of scrollbar "Progressbar" to item 2 of pStatus
   end if
   
   -- better text information
   if the number of items in pStatus = 3 then
      put item 2 of pStatus into tBytesReceived
      put item 3 of pStatus into tTotalBytes
      
      -- this gives very large numbers that are not easily read, so convert to KB
      put tBytesReceived div 1024 into tKBreceived
      put tTotalBytes div 1024 into tTotalKB
      
      -- calculate speed
      put the seconds - sDownloadStart into tElapsedSeconds
      if tElapsedSeconds = 0 then
         -- make sure we don't divide by zero at the start
         put "unknown" into tKBperSecond
      else
         put round(tKBreceived / tElapsedSeconds, 1) into tKBperSecond
      end if
      
      put "Received (KB): " & tab & tKBreceived &cr & "Of Total (KB: " & tab &  tTotalKB & cr &\
            "At KB/sec: " & tab & tKBperSecond into fld "ProgressField"
      
   end if
end showProgress

command downloadComplete pURL, pStatus
   -- this is the handler called when the download is finished
   -- the pStatus variable will show the result
   
   -- since the download is complete, there is no need to leave the progress bar visible
   local error, tModule, tLocalPath
   
   hide scrollbar "ProgressBar"
   
   -- check if there was a problem with the download
   if pStatus = "error" or pStatus = "timeout" then
      put error  &cr& "The file could not be downloaded. Try later." into fld "ProgressTitle"
      wait 1 second with messages
      put removeQuotes(sRequestedBy) into tModule     
      tracking_RecordActivity tModule,"download/failed"
      hidedDownloadControls
   else
      put  path_FileFromURL(sURL) into tLocalPath # includes filename
      put URL pURL into URL ("binfile:" & tLocalPath)
      
      -- to save memory, now unload the URL from memory
      -- this also means that if you want to run the test again, it does not just use a cached version
      unload pURL
      
      delete word 1 to 4 of sRequestedBy
      dispatch "updateCachedListings"  to sRequestedBy with sRecordNumber
      hidedDownloadControls
      put removeQuotes(sRequestedBy) into tModule     
      tracking_RecordActivity tModule,"download/saved"
   end if
end downloadComplete

on mouseup
   local tMouseEvent
   
   put the short name of target() into tMouseEvent
   switch tMouseEvent
      case "cancel"
         unload sURL
         --close this stack
         break
   end switch
   hidedDownloadControls
end mouseup

on hidedDownloadControls
   local tLastStack
   put empty into fld "ProgressTitle"
   put empty into fld "progressField"
   hide scrollbar "progressbar"
   hide grp "downloadControls"
end hidedDownloadControls
