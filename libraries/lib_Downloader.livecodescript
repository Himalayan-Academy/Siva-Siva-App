script "lib_Downloader"

-------------------------------
-- vars

global gDownloader
local sSelectedItemA


on initSync pTitle
   put "Downloading" && pTitle into fld "progress title"
   set the thumbPosition of scrollbar "progress" to 0
   put empty into fld "progress display"
end initSync

--------------------------------
-- IsFileOnDisk/FileForURL
-- DESCRIPTION:
-- Called from any stack that wants to use local media
-- or download it if not available
-- see init script which sets up folders in /media to match
-- the web server; CMS in app is the same:
-- files are in a folder with the  fileID from the database.
-- PARAMS:
-- you must pass the full path from DOCROOT
-- from the fully constructed URL
-- which is returned by the media library
-- e.g. https://www.himalayanacademy.com/media/audio/inspired-talks/bodhinatha/2017/[fileId]/[fileId].mp3
-- We will clear the absolute URL string here as lib_SivaSivaMedia always
-- Returns a fully qualified URL.

function isFileOnDisk pURL
   put pathFromURL(pURL) into tLocalPath
      put specialFolderPath("documents") into tDF
   if there is a file fileForUrl(pURL) then
      return true
   end if
   return false
end isFileOnDisk

function fileForUrl pURL
   put specialFolderPath("documents")
   put the defaultFolder into tDF
   set the itemdel to "/"
   put item -1 of pURL into tFile
   put item 5 to -2 of pURL into tPath
   switch the platform
      case "macos" 
         put "~" & specialFolderPath("asup") & "/" & kAppName into tFolder
         break
      case "win32"
         put specialFolderPath("0x001a") & "/" & kAppName into tFolder
         break
   end switch
   
   if there is not a folder tFolder then
      create folder tFolder
   end if
   
   set the defaultFolder to tFolder
   
   repeat for each item tPathItem in tPath
      if there is not a folder tPathItem then
         create folder tPathItem
      end if
      set the defaultFolder to tPathItem
   end repeat
   
   set the defaultFolder to tDF
   
   return tFolder & "/" & tPath & "/" & tFile
end fileForUrl

on loadMediaItem pFileID,pMediaTitle,pURL
   lock screen
   if isMediaOnDisk(pFileID) then
  # do nothing... 
   else
      answer question (pMediaTitle &&"is not cached. Download now?") with "No"or "Yes"
        if it is "Yes" then
         dispatch "downloadtPlaylistClasspdfs" to stack "program" with pId
         dispatch "downloadtPlaylistClassthumbnails" to stack "program" with pId
         dispatch "waitTillMagazineIsLoaded" to me with pId, "loadMagazine"
      else
         hide widget "download"
      end if
   end if
end loadMediaItem

on processDownloadOneItem pURL
   libURLSetStatusCallback "downloadstatusbroadcaster", the long ID of this stack
   load URL pURL with message "DownloadQueueCallback"
   dispatch "DownloadStatusBroadcaster" to this stack with pURL
end processDownloadOneItem


# taken from HT Navigator  for more than one file at a time;
-- on processDownloadQueue
--    debug "process download queue called."
--    glxapp_publishBroadcast "gNAVIGATOR", "statuschange", "statuschanged"

--    if the keys of gNAVIGATOR["download queue"]["scheduled urls"] is empty then
--       put false into gNAVIGATOR["flags"]["processdownloadqueue"]
--       exit processDownloadQueue
--    end if
--    /*
--    if gNAVIGATOR["flags"]["processDownloadQueue"] is not false then
--       put "already running"
--       exit processDownloadQueue
--    end if
--    */
--    put the keys of gNAVIGATOR["download queue"]["scheduled urls"] into tFiles
--    sort tFiles
--    repeat with x = 1 to the number of lines in tFiles
--       put line x of tFiles into tURL
--       if gNAVIGATOR["download queue"]["scheduled urls"][tURL] is "scheduled" then
--          if there is not a file fileForUrl(gNAVIGATOR["download queue"]["scheduled urls"][tURL]) then
--             debug "loading url" && tURL
--             put "trying to download" && tURL
--             libURLSetStatusCallback "downloadstatusbroadcaster", the long ID of stack "program"
--             load URL tURL with message "DownloadQueueCallback"
--             put true into gNAVIGATOR["flags"]["processdownloadqueue"]
--             dispatch "DownloadStatusBroadcaster" to stack "program" with tURL
--             exit repeat
--          end if
--       end if
--    end repeat   
-- end processDownloadQueue

on trim @pVar
   repeat while char 1 of pVar is in format(" \t\n")
      delete char 1 of pVar
   end repeat
   repeat while char -1 of pVar is in format(" \t\n")
      delete char -1 of pVar
   end repeat
end trim

on clearDebugInformation
   put empty into gNAVIGATOR["debug"]
end clearDebugInformation

on debug pMsg
   put pMsg & cr into gNAVIGATOR["debug"][the millisecs]
end debug



function slashes
   repeat with x = 1 to the paramCount
      put param(x) & "/" after tReturnValue
   end repeat
   delete char -1 of tReturnValue
   return tReturnValue
end slashes

on setup
   setDefaultFolder
   databaseSetup
   glxapp_publishBroadcast "gNAVIGATOR", "statuschange", "statuschanged"
   glxapp_publishBroadcast "gNAVIGATOR", "downloadscheduled", "downloadscheduled"
   glxapp_publishBroadcast "gNAVIGATOR", "downloadcomplete", "downloadcomplete"
   glxapp_publishBroadcast "gNAVIGATOR", "loadtPlaylistClass", "loadtPlaylistClass"
   
   # Create some objects for easy access
   /*
   put sqlquery_createObject("tPlaylistClasss") into theQueryA
   sqlquery_retrieveAsArray theQueryA, theArrayA
   repeat for each key tMagazine in theArrayA
      put tPlaylistClassById(theArrayA[tMagazine]["id"]) into gNAVIGATOR["tPlaylistClasss"][theArrayA[tMagazine]["id"]]
   end repeat
   put tPlaylistClassById(currentMagazine()) into gNAVIGATOR["current tPlaylistClass"]  
   */ 
end setup


on Err pVar
   if pVar is not empty then
      answer error pVar
      exit to top
   end if
end Err

on errorDialog executionError, parseError
   answer error format("Error in execution: %s\nError in parsing: %s", executionError, parseError)
   pass errorDialog
end errorDialog
   

on loadAllCovers
   # Load all tPlaylistClasss that have a cover field in tCoversA
   put sqlquery_createObject("tPlaylistClasss") into theQueryA
   put "tPlaylistClasss.cover is :1" into theConditions
   sqlquery_setConditionsFromUserSearchString theQueryA, empty, theConditions
   sqlquery_retrieveAsArray theQueryA, tCoversA
   repeat for each key tIssue in tCoversA
      put "http://www.hinduismtoday.com/archives/" & tCoversA[tIssue]["year"] & "/" & \
            tCoversA[tIssue]["month"] & "/" & \
            tCoversA[tIssue]["cover"] & cr after tCoverFileURL
   end repeat
   filter tCoverFileURL with "*jpg*"
   sort tCoverFileURL
   repeat for each line tFile in tCoverFileURL
      scheduleForDownload tFile
   end repeat
   dispatch "processDownloadQueue" to stack "program"
end loadAllCovers



on scheduleForDownload pURL
   debug "scheduleForDownload called for"&& pURL
   if isFileOnDisk(pURL) is false then
      libURLSetStatusCallback "downloadstatusbroadcaster", the long ID of stack "program"
      debug "scheduling url" && pURL
      put "scheduled" into gNAVIGATOR["download queue"]["scheduled urls"][pURL]
      glxapp_broadcast "gNAVIGATOR", "downloadscheduled", gNAVIGATOR["download queue"]["scheduled urls"][pURL]
   end if
end scheduleForDownload
   

   
on processDownloadQueue
   debug "process download queue called."
   glxapp_publishBroadcast "gNAVIGATOR", "statuschange", "statuschanged"
    
   if the keys of gNAVIGATOR["download queue"]["scheduled urls"] is empty then
      put false into gNAVIGATOR["flags"]["processdownloadqueue"]
      exit processDownloadQueue
   end if
   /*
   if gNAVIGATOR["flags"]["processDownloadQueue"] is not false then
      put "already running"
      exit processDownloadQueue
   end if
   */
   put the keys of gNAVIGATOR["download queue"]["scheduled urls"] into tFiles
   sort tFiles
   repeat with x = 1 to the number of lines in tFiles
      put line x of tFiles into tURL
      if gNAVIGATOR["download queue"]["scheduled urls"][tURL] is "scheduled" then
         if there is not a file fileForUrl(gNAVIGATOR["download queue"]["scheduled urls"][tURL]) then
            debug "loading url" && tURL
            put "trying to download" && tURL
            libURLSetStatusCallback "downloadstatusbroadcaster", the long ID of stack "program"
            load URL tURL with message "DownloadQueueCallback"
            put true into gNAVIGATOR["flags"]["processdownloadqueue"]
            dispatch "DownloadStatusBroadcaster" to stack "program" with tURL
            exit repeat
         end if
      end if
   end repeat   
end processDownloadQueue
  
on DownloadStatusBroadcaster pURL, pStatus

   show img "network communication"
   glxapp_broadcast "gNAVIGATOR", "statuschange"
   #put the ticks && pURL && pStatus
   put pStatus into gNAVIGATOR["download queue"]["scheduled urls"][pURL]
end DownloadStatusBroadcaster
 
on DownloadQueueCallback pURL, pStatus
   hide img "network communication"
   put pStatus into gNAVIGATOR["download queue"]["scheduled urls"][pURL]
   switch word 1 of pStatus
      case "cached"
         put URL pURL into URL ("binfile:" & fileForUrl(pURL))
         delete variable gNAVIGATOR["download queue"]["scheduled urls"][pURL]
         unload pURL
         glxapp_broadcast "gNAVIGATOR", "statuschange"
         put pURL into theDataA["file"]
         glxapp_broadcast "gNAVIGATOR", "downloadcomplete",theDataA["file"]
         put false into gNAVIGATOR["flags"]["processdownloadqueue"]
         dispatch "processDownloadQueue" to stack "program"
         break
      case "error"
      case "timeout"
         # Download timed out or error, reset sockets and re-schedule
         add 1 to gNAVIGATOR["error count"]
         if gNAVIGATOR["error count"] >= 3 then
            answer error "Could not download the needed files. Try again later"
            put 0 into gNAVIGATOR["error count"]
            go card "archives"
            exit DownloadQueueCallback
         end if
         resetAll
         glxapp_broadcast "gNAVIGATOR", "statuschange"
         dispatch scheduleForDownload to stack "program" with pURL
         dispatch processDownloadQueue to stack "program"
         break
      default
   end switch
end DownloadQueueCallback

command _UTILITIES
end _UTILITIES

function pathFromURL pURL
   if char 1 to 4 of pURL <> "http" then
      # this is not a fully qualified URL
      put "not a complete url"
   else
      set the itemdel to "/"
      delete item 1 to 3 of pURL
      return pURL
   end if
   
end pathFromURL

command _OLDHTNAVIGATOR
   
end _OLDHTNAVIGATOR

-- function currentMagazine
--    put sqlquery_createObject("tPlaylistClasss") into theQueryA
--    Err the result
--    sqlquery_set theQueryA, "order by", "tPlaylistClasss.id"
--    Err the result
--    sqlquery_retrieveAsArray theQueryA, theArrayA
--    Err the result
--    put the keys of theArrayA into tKeys
--    sort numeric tKeys
--    get line -1 of tKeys
--    get theArrayA[it]["id"]
--    return it
-- end currentMagazine

-- on loadCurrentIssue
--    loadMagazine currentMagazine()
-- end loadCurrentIssue


-- function isMagazineOnDisk pID
--    put tPlaylistClassById(pID) into tMagazineA
--    if there is not a file fileForUrl(tPlaylistClassCover(pID)) then
--       return false
--    end if
--    repeat for each key tKey in tMagazineA["items"]
--       if tMagazineA["items"][tKey]["type"] is "pdf" then
--          if there is not a file fileForUrl(tMagazineA["items"][tKey]["reference"]) then
--             return false
--          end if
--       end if
--    end repeat
--    return true
-- end isMagazineOnDisk

-- on waitTillMagazineIsLoaded pId, pCallback
--    if the keys of gNAVIGATOR["download queue"]["scheduled urls"] is empty then
--       dispatch pCallback to the target with pId
--    else
--       if the environment is "development" and the optionKey is down then
--          exit waitTillMagazineIsLoaded
--       end if
--       send "waitTillMagazineIsLoaded pId, pCallback" to me in 1 secs
--    end if
-- end waitTillMagazineIsLoaded

-- on downloadMagazinePDFs pID
--    clearDebugInformation
--    put tPlaylistClassById(pID) into tMagazineA
--    scheduleForDownload tPlaylistClassCover(pID)
--    repeat for each key tKey in tMagazineA["items"]
--       if tMagazineA["items"][tKey]["type"] is "pdf" then
--          scheduleForDownload tMagazineA["items"][tKey]["reference"]
--       end if
--    end repeat
--    dispatch processDownloadQueue to stack "program"
-- end downloadMagazinePDFs

-- on downloadMagazineThumbnails pID
--    clearDebugInformation
--    put tPlaylistClassById(pID) into tMagazineA
--    repeat for each key tKey in tMagazineA["items"]
--       if tMagazineA["items"][tKey]["thumbnail"] is not empty then
--          scheduleForDownload tMagazineA["items"][tKey]["thumbnail"]
--       end if
--    end repeat
--    dispatch processDownloadQueue to stack "program"
-- end downloadMagazineThumbnails

-- function tPlaylistClassItemsById pId
--    put sqlquery_createObject("items") into theQueryA
--    put "items.tPlaylistClass is :1" into theConditions
--    sqlquery_setConditionsFromUserSearchString theQueryA, pId, theConditions
--    Err the result
--    sqlquery_set theQueryA, "order by", "items.layer"
--    Err the result
--    sqlquery_retrieveAsArray theQueryA, theArrayA
--    Err the result
--    return theArrayA
-- end tPlaylistClassItemsById

-- function tPlaylistClassById pId
--    put sqlquery_createObject("tPlaylistClasss") into theQueryA
--    put "tPlaylistClasss.id is :1" into theConditions
--    sqlquery_setConditionsFromUserSearchString theQueryA, pId, theConditions
--    Err the result
--    sqlquery_retrieveAsArray theQueryA, theArrayA
--    Err the result
--    repeat for each key tKey in theArrayA[1]
--       put theArrayA[1][tKey] into tResultA[tKey]
--    end repeat
--    put tPlaylistClassItemsById(pId) into tResultA["items"]
--    return tResultA
-- end tPlaylistClassById

-- function findItemsByKeyword pItemsA
--    repeat for each key tKey in pItemsA
--       repeat with x = 2 to the paramCount
--          if param(x) is in pItemsA[tKey]["keywords"] then
--             add 1 to y
--             put pItemsA[tKey] into tA[y]
--          end if
--       end repeat
--    end repeat
--    return tA
-- end findItemsByKeyword

-- function findItemsByType pItemsA
--    repeat for each key tKey in pItemsA
--       repeat with x = 2 to the paramCount
--          if param(x) is in pItemsA[tKey]["type"] then
--             add 1 to y
--             put pItemsA[tKey] into tA[y]
--          end if
--       end repeat
--    end repeat
--    return tA
-- end findItemsByType



-- function tPlaylistClassCover pId
--    put tPlaylistClassById(pId) into tMagazineA
--    get slashes(tMagazineA["year"], tMagazineA["month"], tMagazineA["cover"])
--    return "http://www.hinduismtoday.com/archives/" & it
-- end tPlaylistClassCover

-- on openMagazineItem pItemA
--    switch 
--       case "pdf" is in pItemA["type"]
--          if there is a file fileForUrl(pItemA["reference"]) then
--             launch document fileForUrl(pItemA["reference"])
--             if the currentcard of this stack is "downloads" then
--                go recent card
--                if the currentcard of this stack is "issue" then
--                   dispatch "buildtoc" to card "issue" with pItemA["tPlaylistClass"]
--                end if
--             end if
--          else
--             if the currentcard of this stack is not "issue" then
--                answer info "This file is not cached, do you want to download it now?" with "Go to Table of Contents" and "Yes" and "No"
--             else
--                answer info "This file is not cached, do you want to download it now?" with "Yes" and "No"
--             end if
--             switch it
--                case "yes"
--                   go card "downloads"
--                   --dispatch "downloadtPlaylistClasspdfs" to stack "program" with pItemA["tPlaylistClass"]
--                   scheduleForDownload pItemA["reference"]
--                   dispatch "waitTillMagazineIsLoaded" to me with pItemA, "opentPlaylistClassitem"
--                   send "processDownloadQueue" to me
--                   break
--                case "Go to Table of Contents"
--                   if the currentcard of this stack is not "issue" then
--                      go card "issue"
--                      dispatch "buildtoc" to card "issue" with pItemA["tPlaylistClass"]
--                   end if
--                   break
--             end switch
--          end if
--          break
--       case "html" is in pItemA["type"]
--       case "audio" is in pItemA["type"]
--       case "video" is in pItemA["type"]
--          mediaDisplay pItemA
--       default
--    end switch
-- end openMagazineItem
