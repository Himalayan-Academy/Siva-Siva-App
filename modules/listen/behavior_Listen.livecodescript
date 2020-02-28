script "behavior_Listen"

-----------------------------------------------------
#  behavior_Listen
#
# DESCRIPTION
# this behavior is the /modules/listen/listen.livecode stack script
# It's primary function is to handle high level calls to get play lists
# UI consist of 3 main cards
# listen-collections - shows a catalog of songs built up on a 
# collection.json for: it in be built from a development stack tools
# listen-browse - Later for show in play list
# listen-my-music  # for music that is no loaded
#
# So as not to over load this script the handlers whose scope deals with
# user interaction with a single play list/ indivdtual songs are in a separate behavior 
#
# behavior_ListenSelectPlay
# assigned to the listen-browse card
#
# PARAMS: Main variable sent to this script is a string JSONl list 
#  which is the name/title of all the collections
#
# CHANGES: 2017-06-22 CREATED Brahmanathaswami
-----
global sConfigA
local sCollectionA,sCollectionChoice,  sSelectedItemA, sSelectedURL, sDownloadedAudioA
local sCurrentPlayListA,sTargetPlayList,sListType,sPlaylistQueryA,sShareURL,sOnLIne
local sNowPlayingTitle, sNowPlayingArtist,sNowPlayingDetails,sStartTimer,sEndTimer
local sCached, sBrowseHeader, sTimeStamp, sRemoteURL
local sSelectionsA,sLastTarget,sLineNum,sSelectNum

on preopenstack
   set the fullscreenmode of this stack to "showAll"
   if isMobile() then
      mobileSetFullScreenRectForOrientations "portrait,portrait upside down","0,0,414,736"
      set the fullscreenmode of this stack to "showAll"
      iphoneSetAudioCategory "playback" 
   end if
end preopenstack

on openstack 
   #V2 April 8, 2018
   # 
   # and these are basically playlists like on Spotify, though
   # some might qualify as albums, but we don't have enough to 
   # make a differentiation. So treat all as playlists 
   # we get playlist from the json file, that is attached
   # to the mouse down one the group number
   #
   # first, load the json
   
local tContainer
   
   set the acceleratedRendering of this stack to true
   
   put url ("binfile:" & path_Modules()& "listen/collection.json") into tContainer
   put JSONToArray(tContainer) into sCollectionA 
   
   portal_SetLastStack "Listen"
   if isMobile() then
      mobileShowStatusBar
   end if
   
   # must have net connection, otherwise take to My Audio
end openstack


# return JSON for other handlers as needed

function getCollectionsJson
   return sCollectionA
end getCollectionsJson


command selectPlaylist pSelection
   local tPlayTarget,tColl,tPlay
   
   # use has  made choice from card 
   
   
   
   # get extract JSON from sCollectionA 
   # which is an array that contain all collections
   # it include the data we need to the title and path to img file.
   # but this pre-built for production
   # you can rebuild the UI from the SivaSivaDev Tool.livecode stacks
   
   
   put the short name of pSelection into tPlayTarget
   
   # first - card navigition
   
   if tPlaytarget contains "my-audio" then
      go to card "listen-my-audio"
      exit selectPlayList
   end if
   
   # other wise we are select a collection:
   
   if not (tPlayTarget contains "-playlist-") then
      exit to top
   else
      # we should put this a common library, but the are too many sceneros per moldule
      offLineGoMyAudio
   end if
   
   set the itemDelimiter to "-"
   put item 1 of tPlayTarget into tColl
   put item 2 of tPlayTarget into tPlay
   
   # Link each separate process to a 
   # specific handler
   playList_FetchData tColl,tPlay
end selectPlaylist

-----------------------------------------------------
# playlist_SetGetCurrent
# DESCRIPTION:  the primary known variable is a string 
# which taken from the json list on mouseup (see selectPlayList above
#
# PARAMS: pass the playlist string, which should also serve as it's title 
# See the JSON for more detail on what is on the aray
# see /models/model_SivaSiva/model_SivaSiva.json 
# CHANGES: Created 2017-06-22 Brahmanathaswami
------------------------------------------------------

# more need to set the playListLater
# and other playListClass
# what we have a setter/getter here
on playlist_GetClass
   return sCurrentPlayListA["playlistClass"]
end playlist_GetClass

on playlist_SetCurrent pList  
   put pList into sTargetPlayList
end playlist_SetCurrent

function playlist_GetCurrent
   return sCurrentPlayListA["playListTitle"]
end playlist_GetCurrent

# we may need to fetch files later
# so another function returns the key listen list to build everything
# includes the metadata from the date base, the lyrics and the URL
# use this to fetch data later for card behavior

function playlist_GetRecords  
   if sCurrentPlayListA["audioFiles"] is empty then     
      --       if isMobile() is false then
      --          put "No records Fetched!"
      --       end if   
   else
      return sCurrentPlaylistA
   end if
end playlist_GetRecords

-----------------------------------------------------------------------
# playList_FetchData
# DESCRIPTION: 
-- # all the dataquery data it in to json file under "data-query"
-- # we have three classes of lists based on data storage/CMS
-- # each requires a different query
-- # 1. Remote list: send JSON to server we send JSON for remote list
-- # 2.  Audiobook: build a path string and download index. json for audio books
-- # 3. query the local dbase for already cached metadata in the Local Jnanam dbase
-- # These are merged into a sPlaylistQueryA   array the we use pass date to the 
-- # dbase handlers
-- # we need max six criteria to search our metadata, not all playlists require all strings, 
-- # but our query array will still have all these keys; use elements as needed
-- # we will model that array into a json string or dbase query later
-- # media_type, author, artist, record-type [latest | cached | audiobook], num-of-records,year, file_id
-- # see /system/applications/ha/controllers/API3.lc  on the server for details on the remote call
-- #  structure of remote query, for reference:
-- # Note we use "recordType" here instead of "playlistClass" because the API  pon the server is agnostic about the type
-- # of records we are fetching... it could be artwork quotes, books anything... not only audio playLists.
-- #   put "{'data': {'media_type': 'inspiredtalk','author':'Bodhinatha'},'recordType':'latest','recordCount':'30'}" into tJSON
-- #
-- # We keep all the data in json file now.

-- # Audio books are simpler, all we need is a path to the remote server directory, fetch the audio JSON file therein.
-- # 
-- # Sorting differs by playlistClass: latest | descending by date, audiobook | per json index, cached | alpha by title or file_ID
-- # usually trigger on arrival to this stack-card

-- # PARAMS: pass numeric collection and the playlist from /modules/listen/collection.json file
-- # CHANGES: 2018-04-09 - BR Created

# secondary params"
#  from json file: this is a sample. Not all playlists require all params
--          put "playListClass" into sPlaylistQueryA["playlistClass"]  # gets metadata from remote server
--          put "inspiredtalk" into sPlaylistQueryA["media_type"]         
--          put "Satguru Bodhinatha Veylanswami" into sPlaylistQueryA["author"]
--          put "latest" into sPlaylistQueryA["recordType"]        
--          put 30 into sPlaylistQueryA["recordCount"] 
--          put "master-course" into sPlaylistQueryA["file_id"]
--          put "1970" into sPlaylistQueryA["date_created"]
--          put "YES" into sPlaylistQueryA["approved_for_public"]

-----------------------------------------------------------------------

on playList_FetchData tColl,tPlay,pFilterListQueryA,pBrowseHeader
   local tPlaylistClass, tRecordTypeCount, tDbaseColumns
   local  queryData, pJSON, tRecords, tSearchA, tFileID, tTocURL, tBookToc
   
   
   showBusyIndicator true,"Loading"
   put empty into fld "audioList" of card "listen-browse" of stack "listen"
   
   --  dispatch "cleanUpGui" to card "listen-browse"      
   
   put empty into sPlaylistQueryA 
   
   # if pFilterListQueryA is empty, it means we are coming in
   # the Search and Filter filter screen
   # if not, we coming of the main collection screen
   
   if pFilterListQueryA = empty then 
      
      put sCollectionA[tColl]["playlists"][tPlay]["playListClass"] into tPlaylistClass 
      put sCollectionA[tColl]["playlists"][tPlay]["playListTitle"]  into  sCurrentPlayListA["playListTitle"]
      
      
      put tPlaylistClass into sPlayListQueryA["PlaylistClass"]
      
      # decides if cached on device, or from server and audio book
      # this param is used here... not sent to the database. 
      # but use to determine how the query show go: the server, audio book, in the local mySQL jnanam (local dbase_
      # get type of playlistL audio book, etc
      
      # first we need action the array from the json able 
      # everything in needs to create a query
      
      put "recordType,recordCount" into tRecordTypeCount
      
      # remember: tColl and tPlay are drawn from the mouseups
      # see the nomenclature for what the mouseup calls for
      # in the IDE project browser
      
      repeat for each item RT in tRecordTypeCount
         if (sCollectionA[tColl]["playlists"][tPlay][RT] is not empty) then 
            put  sCollectionA[tColl]["playlists"][tPlay][RT] into sPlayListQueryA[RT]
         end if 
      end repeat
      # you must declare all columns you are searching in the data base.
      put "media_type,file_id,approved_for_public,author,genre,deity,tags" into tDbaseColumns
      
      repeat for each item DC in tDbaseColumns
         if ( sCollectionA[tColl]["playlists"][tPlay]["data_query"][DC] is not empty) then 
            put sCollectionA[tColl]["playlists"][tPlay]["data_query"][DC] into sPlayListQueryA[DC]
         end if
      end repeat
      put sCurrentPlayListA["playListTitle"] into sBrowseHeader
      replace cr with " " in sBrowseHeader
   else
      # use the queries from the Search Screen
      
      put "cached" into tPlayListClass
      put pFilterListQueryA into sPlaylistQueryA
      # the query is sent a param for the header
      put pBrowseHeader into sBrowseHeader
      
   end if
   
   
   # we get records now, from server, or local jnanam.
   # we get each one based the on class, on where they come from
   
   switch tPlaylistClass
      case "latest" 
         # we do a JSON Call  to the server
         # use the a function in lib_SivaSivaMedia to model this array sPlaylistQueryA into the pJSON
         # we need because we can then use for different play lists on demand..          
         # the sPlayListQueryA  has the values needed for the API... 
         # API requires taht we construct data: 
         # set the query;  recordtype/Count  
         # set up how many/limit the number of records to return which are 
         # different function in the API, SQL ; Note look at the API2.livecode ; getItemRecords handler
         # e.g. required format need single quotes to go thru the API
         #  "{'data': {'media_type': 'inspiredtalk','author':'Satguru Bodhinatha Veylanswami'},'recordType':'latest','recordCount':'30'}"
         #  API is agnostic about query strings... if you just pass media type "song" with author or artist you get all the latest songs.
         #  just sets the WHERE clause in the query with whatever you request. 
         # Then sorts on date sends back the request number of records.
         
         --breakpoint
         
         put "Contacting server... " into fld "audioList" of card "listen-browse"
         
         # Set up the WHERE clause
         put sPlayListQueryA["media_type"] into queryData["data"]["media_type"]
         put sPlayListQueryA["author"] into queryData["data"]["author"] 
         put sPlayListQueryA["recordType"] into queryData["recordType"]
         put sPlayListQueryA["recordCount"] into queryData["recordcount"]
         
         put arrayToJson(queryData) into pJSON # from server
         
         put the ticks into sStartTimer
         set the httpheaders to "content-type: application/json"
         
         ## TO DO:  NEEDED: TIME OUT REQUIREMENT!
         POST pJSON to URL "http://dev.himalayanacademy.com/api3/getItemRecordsAndFormats/json"
         
         if the result is not empty then 
            put "Check your network connection." into  fld "audioList" of card "listen-browse" of stack "listen"
            dialog_CustomMsg "Offline or Low Bandwidth"
            portal_Link "Listen"
            exit to top
         else 
            put it into tRecords
            
            put jsonToArray (tRecords) into sCurrentPlayListA["audioFiles"]
         end if
         # add list type for other operations
         put tPlaylistClass into sCurrentPlayListA["playlistClass"]  #now we have our local array
         break
      case "cached"
         put sPlaylistQueryA into tSearchA
         delete variable tSearchA["playlistClass"]  # don't pass this to the query
         put fetchMediaItems(tSearchA) into sCurrentPlayListA["audioFiles"]
         put tPlaylistClass into sCurrentPlayListA["playlistClass"] 
         break
      case "audiobook"
         put "Contacting server... " into fld "audioList" of card "listen-browse"
         # a simple call to the server to get the TOC
         # can chose different books base on file_id
         put sPlaylistQueryA["file_id"] into tFileID
         
         # CMS is straightforward, path is consistent, no magic code required
         
         ## TO DO:  NEEDED: TIME OUT REQUIREMENT!
         put "https://www.himalayanacademy.com/media/audio/books/" & tfileID & "/audiobook.json"   into tTocURL
         put URL tTocURL into tBookToc
         if the result is not empty then 
            put "Check your network connection." into  fld "audioList" of card "listen-browse" of stack "listen"
            dialog_CustomMsg "Offline or Low Bandwidth"
            showBusyIndicator false
            exit to top
         else 
            put jsonToArray(tBookToc) into sCurrentPlayListA["audioFiles"]
         end if
         # this should come from the local dBase,
         # but as of June 29, the local dBase is obsolete
         
         # so we have to fetch info from the server 
         # this does not include a data base query other than the file id
         # which get the URL and pull to TOC.json for the audio book.
         
         put "{'data': {'media_type': 'audio/book','file_id':'" & tFileID&"'}}" into pJSON 
         set the httpheaders to "content-type: application/json"
         replace "'" with quote in pJSON
         
         ## TO DO:  NEEDED: TIME OUT REQUIREMENT!
         POST pJSON to URL "http://dev.himalayanacademy.com/api3/getItemRecordsAndFormats/json"         
         if the result is not empty then 
            put "Check your network Connections" into  fld "audioList" of card "listen-browse" of stack "listen"
            dialog_CustomMsg "Offline or Low Bandwidth"
            showBusyIndicator false
            exit to top
         else 
            put it into tRecords 
            # But the model is different for audio books. We now have metadata for the whole book
            # this is not a series of records for individual files
            # We need this later:
            put jsonToArray (tRecords) into sCurrentPlayListA["audioBookMetadata"]
            put tFileID into sCurrentPlayListA["audioBookMetadata"]["file_id"]
         end if
         
         break      
   end switch
   
   -- put (the ticks - sStartTimer)  early tests: as long as 3 minutes to get data from the server...
   # we have the data for our records in the array now.
   # need know two things from the beginning
   put tPlaylistClass into sCurrentPlaylistA["playlistClass"]
   
   if sCurrentPlayListA["audioFiles"] is empty then 
      doAnswer "No records for that search. Try again","Cancel"
      showBusyIndicator false
      put empty into fld "audioList" of card "listen-browse" of stack "listen"
      exit to top
   end if
   
   
   playlist_Instantiate sTargetPlayList
   
end playList_FetchData


-----------------------------------------------------------------------
# playlist_Instantiate
#
# DESCRIPTION: 
# card 1 of this stack must always be card "listen-playlist" 
# as such, object references here refer to controls on that card
# this is where we fill in the play list 
#
# PARAMS: everything is taken from the sCurrentPlaylistA array
#
# CHANGES: 2017-06-22 created Brahmanathswami
-----------------------------------------------------------------------


on  playlist_Instantiate sTargetPlayList    
   Local tKeys, tTitles, pData
   # using: model_SivaSiva, which has functions to get json info we need:
   
   switch sPlaylistQueryA["playlistClass"] 
      case "audiobook"
         put the keys of sCurrentPlayListA["audioFiles"]["toc"] into tKeys
         sort lines of tKeys ascending numeric
         repeat for each line x in tKeys
            put sCurrentPlayListA["audioFiles"]["toc"][x]["label"] & cr & cr after tTitles
         end repeat
         break
      default
         put the keys of sCurrentPlayListA["audioFiles"] into tKeys
         sort lines of tKeys ascending numeric
         repeat for each line x in tKeys
            put sCurrentPlayListA["audioFiles"] [x]["Title"] after tTitles
            
            if sCurrentPlayListA["audioFiles"] [x]["media_type"] ="audio/song" then
               put cr &sCurrentPlayListA["audioFiles"] [x]["artists"] after tTitles
            else
               put cr after tTitles
            end if
            put cr after tTitles
            
         end repeat
   end switch
   put empty into sCached
   
   getPlayListURLs tKeys
   
   --markCachedItems tKeys
   
   showBusyIndicator false
   
   # Now we switch cards, 
   
   go to card "listen-browse"
   
   hide fld "audioList"
   put tTitles into fld "audioList"  
   typesetAudioList
   -- put the number of lines of tTitles into pLineCount
   --  addSpaceBelowListLines (the long id of fld "audioList"), pLineCount, 10
   
   repeat for each line x in sCached
      set the foregroundcolor line (x*2-1) of fld "audioList" to 245,200,190
   end repeat
   replace cr with " " in sBrowseHeader
   put sBrowseHeader into fld "title-label" of card "listen-browse"
   
   show fld "audioList"
   
   
   # here is where we have to check to see if any files are stored locally or not
   
   
   if the formattedHeight fld "audioList" > the height of fld "AudioList" then
      send "CreateScroller audioList" to fld "audioList" of card "listen-browse"
   end if
   put  sTargetPlayList into pData["audio_playlist"]
   tracking_RecordActivity "Listen", "navigation/playlist", pData
end playlist_Instantiate

on playlist_Reset
   put playlist_GetRecords() into  sCurrentPlayListA
end playlist_Reset

function checkPlayList
   return the keys of  sCurrentPlayListA
end checkPlayList

--on playlist_Reset
--   put playlist_GetRecords() into sSelectionsA   
--end playlist_Reset

--function checkPlayList
--   return the keys of sSelectionsA
--end checkPlayList

-----------------------------------------------
--# Select, Play, Listen, Stop UI interactions
-----------------------------------------------
--#
--# DESCRIPTION: Only two jobs here
--#     - show the title
--#     - set the URL for the player
--#    -  do the necessary for the mobile player
--#     - start the player
--# we should move common handlers off to a global  lib (may have them already)
--# because we are going to be doing audio all over the app,
--# not just here.
--# 
--# PARAMS: The selected line get the array element
--# and away we go
--#
--# CHANGES: 2020-02-28, BR: explicit vars entered, moving up msg path to behavior_listen
--# CHANGES: 2017-06-22, BR: CREATED 
-----------------------------------------------

on select_Play  sSelectNum, pitemID, sCardName
   # if item id is empty then defaults to the click line number
   
   local tSearchA, tTargetRecordA, tLocalStatus, pMsg, answerURLunavailable, pTrackdata
   local pTitle,audioFiles
   # if we are coming from a click on the card list then the pItemID will be empty
   # but we may be dropping in from the journal or another type of list that
   # simple passes the item_id for the record.. and there is no pSelectedLIne
   
   if pItemID is empty then # search from the click line
      put getItemURL(sSelectNum) into sRemoteURL
      Put "Connecting..." into fld "currentTitleLabel"
      --   playlist_Reset # needed during dev because we often lose the sSelectedItemA value
      put sCurrentPlayListA["audioFiles"][sSelectNum  ] into sSelectedItemA   
      metadata_SetRecord sSelectedItemA
      put sCurrentPlayListA["audioFiles"][sSelectNum]["myURL"] into sSelectedURL
   else
      put pitemID into tSearchA["item_id"]
      put  fetchMediaItems(tSearchA) into tTargetRecordA # returns only 1 record
      put tTargetRecordA[1] into sSelectedItemA
      metadata_SetRecord sSelectedItemA
      put getMediaURL() into sSelectedURL
      put path_isFileOnDisk(sSelectedURL) into tLocalStatus
   end if
   --put checkURLAvailable(sSelectedURL) into fld "localresult"
   
   if checkURLAvailable(sRemoteURL) is "false" then 
      clearPlayer
      put "Sound file unavailable. Are you connected to the internet? If so, please send feedback with the name song and artist so that we can fix it." into pMsg
      doAnswer pMsg,"OK", answerURLunavailable
      exit to top
   end if
   
   
   # Lyrics fetch is a separate function, see lib_SivaSiva Media
   
   get getSongLyrics(sSelectedItemA["item_id"])
   
   if sRemoteURL = "" then -- jg: don't continue
      put "Media not found" into fld "audioDetails"
      set the height of fld "audioDetails" to the formattedHeight of fld "audioDetails"
      showBusyIndicator false
      exit to top
   end if
   
   startPlayer sRemoteURL, sSelectedItemA["title"]  #see nested behavior_ListenUI
   --Journal_AddEntry  sSelectedItemA["item_id"]
   put "audiotitle="& sSelectedItemA["title"]   into pTrackdata["contentTarget"]
   tracking_RecordActivity "Surprise", "navigation/playaudio", pTrackdata
end select_Play


--on select_Play  sSelectNum, pitemID  # if item id is empty then defaults to the click line number
--   local tSearchA, tTargetRecordA, tLocalStatus, pMsg, answerURLunavailable, pTrackdata
--   local pTitle,audioFiles
--   # if we are coming from a click on the card list then the pItemID will be empty
--   # but we may be dropping in from the journal or another type of list that
--   # simple passes the item_id for the record.. and there is no pSelectedLIne

--   if pItemID is empty then # search from the click line
--      put getItemURL("sSelectNum") into sRemoteURL
--      Put "Connecting..." into fld "currentTitleLabel"
--      --   playlist_Reset # needed during dev because we often lose the sSelectedItemA value
--      put sSelectionsA["audioFiles"]["sSelectNum"] into sSelectedItemA   
--      metadata_SetRecord sSelectedItemA
--      put sSelectionsA["audioFiles"][sSelectNum]["myURL"] into sSelectedURL
--   else
--      put pitemID into tSearchA["item_id"]
--      put  fetchMediaItems(tSearchA) into tTargetRecordA # returns only 1 record
--      put tTargetRecordA[1] into sSelectedItemA
--      metadata_SetRecord sSelectedItemA
--      put getMediaURL() into sSelectedURL
--      put path_isFileOnDisk(sSelectedURL) into tLocalStatus
--   end if
--   --put checkURLAvailable(sSelectedURL) into fld "localresult"

--   if checkURLAvailable(sRemoteURL) is "false" then 
--      clearPlayer
--      put "Sound file unavailable. Are you connected to the internet? If so, please send feedback with the name song and artist so that we can fix it." into pMsg
--      doAnswer pMsg,"OK", answerURLunavailable
--      exit to top
--   end if


--   # Lyrics fetch is a separate function, see lib_SivaSiva Media

--   get getSongLyrics(sSelectedItemA["item_id"])

--   if sRemoteURL = "" then -- jg: don't continue
--      put "Media not found" into fld "audioDetails"
--      set the height of fld "audioDetails" to the formattedHeight of fld "audioDetails"
--      showBusyIndicator false
--      exit to top
--   end if

--   startPlayer sRemoteURL, sSelectedItemA["title"]  #see nested behavior_ListenUI
--   --Journal_AddEntry  sSelectedItemA["item_id"]
--   put "audiotitle="& sSelectedItemA["title"]   into pTrackdata["contentTarget"]
--   tracking_RecordActivity "Surprise", "navigation/playaudio", pTrackdata
--end select_Play

# V2 Link to transcript

command select_ShowDetails  pSelection, pRecord
   deleteMobileControl "audioList"
   
   switch
      case (fld "audioList" is empty)
         Put "You have not downloaded any audio yet." into  fld "audioDetails" 
         break
      case (sCurrentPlayListA["playlistClass"] = "latest")  OR (sCurrentPlayListA["playlistClass"] ="cached")
         put getMediaItemMetadata() into fld "audioDetails"
         break
         
         # its an audio book, lib media doesn't know anything, we have to pass the record here   
      case sCurrentPlayListA["playlistClass"]= "audioBook"
         put "Transcripts for audio books are available here." &cr & cr &  "Read the original book." into fld "audioDetails"
         break        
         
         # or its from a downloaded file in My Audio
      case (pSelection="downloaded")
         put  getMediaItemMetadata(pRecord) into  fld "audioDetails"   
         break   
   end switch
   
   set the textsize of line 1 of fld "audioDetails" to 22
   set the textstyle of line 1 of fld "audioDetails" to "bold"
   set the textstyle of line 3 of fld "audioDetails" to "italic"
   set the rect of fld "AudioDetails" to rect of fld "audioList" 
   
   show fld "audioDetails" with visual "effect wipe" up very fast
   send "CreateScroller audioDetails" to fld "audioDetails"
end select_ShowDetails

command typeSetAudioList
   local tX
   put 0 into tX
   repeat with x =1 to the number lines  in fld "audioList"
      add 1 to tX
      if (tX mod 2) = 0 then
         set the leftIndent of line x of fld "audioList" to 10
         if  line x of fld "audioList" <> empty then
            set the spaceBelow of line x of fld "audioList" to 10
         end if   
         set the textSize of line x of fld "audioList" to 15
      else
         set the textSize of line x of fld "audioList" to 17
      end if
   end repeat 
   
end typeSetAudioList

command getPlayListURLs pKeys
   repeat for each line x in pKeys
      --  put getItemURL(x) into sSelectedURL
      put getItemURL(x) into sCurrentPlayListA["audioFiles"][x]["myURL"]
   end repeat   
end getPlayListURLs

function getItemURL pRecordNum
   local tURL
   # send of to lib_SivaSivaMedia, which knows all about our media CMS
   # but Audio books are completely different CMS: they have no item records for their audio files
   
   if ( sCurrentPlayListA["playlistClass"] = "latest")  OR ( sCurrentPlayListA["playlistClass"] ="cached") then
      # everything happens via Jnanam table structure record array
      put  sCurrentPlayListA["audioFiles"][pRecordNum] into sSelectedItemA
      metadata_SetRecord sSelectedItemA
      put getMediaURL (sSelectedItemA["item_id"]) into tURL
      
      # but lib_SivaSivaMedia won't have string for the latest item
      # fortunately there is easily solution for audio:
      --      breakpoint
      --      if char -1 of sSelectedURL = "/" then
      --         put  sCurrentPlayListA["audioFiles"][pRecordNum]["file_id"] & ".mp3" after sSelectedURL
      --      end if   
      --      breakpoint
      if char -1 of sSelectedURL = "/" then
         put  sCurrentPlayListA["audioFiles"][pRecordNum]["filename"]  after sSelectedURL
      end if       
   else
      # its an audio book
      put getMediaURL("audioBook") into tURL
      put  sCurrentPlayListA["audioBookMetadata"]["file_id"] & "/" after tURL
      put  sCurrentPlayListA["audioFiles"]["toc"][pRecordNum]["file"] after tURL
   end if
   return tURL
end getItemURL

command getDownloadedAudio
   local tList, tSearchA, tURL,pFolder,tTitle,tTitles
   
   put empty into sDownloadedAudioA
   # do directory walk of the media/audio folder
   
   put (path_Documents() & "media/audio") into pFolder
   put listFilesWithPaths(pFolder, "true")  into tList
   repeat with x = 1 to (the number of lines of  tList)
      put line x of tList into tURL
      put tURL into sDownloadedAudioA[x]["localURL"]
      set the itemdel to "/"
      put item -2 of tURL into sDownloadedAudioA[x]["file_id"]
      repeat for each  line tKey in the keys of sDownloadedAudioA
         put sDownloadedAudioA[tKey]["file_id"]   into tSearchA["file_id"]
         put  fetchMediaItems(tSearchA) into  sDownloadedAudioA[tKey][metadata]
      end repeat
   end repeat
   
   # first look in the dates base
   
   repeat with x = 1 to (the number lines of keys of sDownloadedAudioA)
      if  sDownloadedAudioA[x]["file_id"] contains "-audiobook" then
         # get in from file names
         set the itemdel to "/"
         put  item -1 of sDownloadedAudioA[x]["localURL"] into tTitle
         put normalizeFileToTitle(tTitle) after tTitles
         put cr & cr after tTitles
         next repeat
      end if
      put sDownloadedAudioA[x][metadata][1]["title"] into tTitle
      
      if tTitle is empty then
         put sDownloadedAudioA[x]["file_id"] into tTitle
         put normalizeFileToTitle(tTitle) after tTitles
      else
         put tTitle after tTitles
      end if
      put cr after tTitles
      if sDownloadedAudioA[x][metadata][1]["media_type"] ="audio/song" then
         put sDownloadedAudioA[x][metadata][1]["artists"] after tTitles
      end if
      put cr after tTitles
      
   end repeat
   
   loadTitles tTitles
   return sDownloadedAudioA
   
end getDownloadedAudio

command downloadSelection sSelectNum, pTarget
   put the long id of pTarget into sLastTarget 
   # NOTE: we need this because the down stack will need to come back where
   # it and we pass this to pRequestBy
   if sSelectNum <> empty then  # we have a selection
      doAnswer "Download this audio file?", "Download,Cancel","downloadAffirmed"
   else
      put "Pick a Title to Download It." into fld "currentTitleLabel"
   end if
end downloadSelection


command downloadAffirmed   
   local pTitle
   if  sCurrentPlayListA["playListClass"] ="audiobook" then
      put  sCurrentPlayListA["audioFiles"]["toc"][sSelectNum]["label"] into pTitle
   else
      put   sCurrentPlayListA["audioFiles"][sSelectNum]["title"]  into pTitle
   end if
   put "listen" into sConfigA["last_stack"]
   hide stack "listen"
   go stack "view_Download"
   wait 100 milliseconds with messages
   dispatch "downloadURL"  to stack "view_Download" with  pTitle,sSelectedURL,sSelectNum,sLastTarget
   # sLastTarget becomes params pRequest by to the download stack
end downloadAffirmed

command loadtitles pTitles   
   local pLineCount
   hide fld "audioList"
   put pTitles into fld "audioList"
   typeSetAudioList
   show fld "audioList"
   put the number of lines of pTitles into pLineCount
end loadtitles

command markCachedItems pKeys
   local pURL, tLocalStatus, tIsCached
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

command addJournalEntry-- save a bookmark to db
   local tData,pDataA, tTitle, tURL
  log sSelectedURL
   
   if the name of this card is "listen-collections" then
      put  "listen-collections" into pDataA["card"]  
   else
      put getMediaMeta() into tData
      put tData["item_id"] into pDataA["item_id"]
      put tData["title"] into pDataA["title"]
      put  tData["url"] into pDataA["url"] 
      log pDataA["url"]
      put "listen-file" into pDataA["card"]  
   end if
   Journal_RecordEntry "listen",tTitle,pDataA -- send to jofrnal
   dialog_CustomMsg "Save To Journal"
end addJournalEntry


on journalResume  pDataA, pEntryA
   -- breakpoint
   
   local tCard
   
   put pDataA["card"] into tCard
   go to card tCard
   
   if tCard= "listen-file"  then
      # using has want to listen you one unique audio file
      # we have set to the card up....  in the the future
      # we can integrate is this listen behavior .
      dispatch "playSingle" to card "listen-file" with pDataA
   end if

end journalResume


------------- 
on __ListenUtilities
end __ListenUtilities

command setAudioListColors tLineNum,pColor
   set the backgroundcolor of line tLineNum of fld "audioList" to pColor
end setAudioListColors

command clearAudioListColor
   set the backgroundcolor of line 1 to -1 of fld "audioList" to empty
end clearAudioListColor


on preopencard
   local tMode, tLabelLoc, tLabelWidth, tBrowseHeader
   # tweak the header for collections
   
   --deleteMobileControl "audioList"  
   
   -- set up the header 
   put the short name of this card into tMode
   switch tMode
      case "listen-collection" 
         
         put the location of fld "collections-label" into tLabelLoc
         put the width of fld "collections-label" into tLabelWidth
         set the width of grc "modeIndicator" to tLabelWidth
         set the location of  grc "modeIndicator" to (item 1 of tLabelLoc, item 2 of tLabelLoc+12) 
         hide fld "browse-label"
         put "Listen" into fld "title-label"
         # have nav bar
         show button "share"
         show button "add-favorites" 
         break
      case "listen-my-audio"
         setAudioListcolors
         put the location of fld "my-audio-label" into tLabelLoc
         put the width of fld "my-audio-label" into tLabelWidth
         set the width of grc "modeIndicator" to tLabelWidth
         set the location of  grc "modeIndicator" to (item 1 of tLabelLoc, item 2 of tLabelLoc+12) 
         hide fld "browse-label"
         put "Downloaded Audio" into fld "title-label"
         put empty into fld "audioList"
         # have nav bar
         show button "share"
         show button "add-favorites" 
         break
      case "listen-browse"
         setAudioListcolors
         put the location of fld "browse-label" into tLabelLoc
         put the width of fld "browse-label" into tLabelWidth
         set the width of grc "modeIndicator" to tLabelWidth
         set the location of  grc "modeIndicator" to (item 1 of tLabelLoc, item 2 of tLabelLoc+12) 
         show fld "browse-label"
         put playlist_GetCurrent() into  tBrowseHeader
         replace cr with " " in tBrowseHeader
         put tBrowseHeader into fld "title-label"
         # have nav bar
         show button "share"
         show button "add-favorites" 
         break
      case "listen-search"
         put the location of fld "title-label" into tLabelLoc
         put the width of fld "title-label" into tLabelWidth
         set the width of grc "modeIndicator" to tLabelWidth
         set the location of  grc "modeIndicator" to (item 1 of tLabelLoc, item 2 of tLabelLoc+12) 
         put "Search" into fld "title-label"
         set the textsize of fld "title-label" to 18
         # have nav bar
         hide button "share"
         hide button "add-favorites" 
         break
   end switch   
end preopencard      put the location of fld "my-audio-label" into tLabelLoc
put the width of fld "my-audio-label" into tLabelWidth
set the width of grc "modeIndicator" to tLabelWidth
set the location of  grc "modeIndicator" to (item 1 of tLabelLoc, item 2 of tLabelLoc+12) 
hide fld "browse-label"
put "Downloaded Audio" into fld "title-label"
put empty into fld "audioList"
# have nav bar
show button "share"
show button "add-favorites" 
break
case "listen-browse"
   setAudioListcolors
   put the location of fld "browse-label" into tLabelLoc
   put the width of fld "browse-label" into tLabelWidth
   set the width of grc "modeIndicator" to tLabelWidth
   set the location of  grc "modeIndicator" to (item 1 of tLabelLoc, item 2 of tLabelLoc+12) 
   show fld "browse-label"
   put playlist_GetCurrent() into  tBrowseHeader
   replace cr with " " in tBrowseHeader
   put tBrowseHeader into fld "title-label"
   # have nav bar
   show button "share"
   show button "add-favorites" 
   break
case "listen-search"
   put the location of fld "title-label" into tLabelLoc
   put the width of fld "title-label" into tLabelWidth
   set the width of grc "modeIndicator" to tLabelWidth
   set the location of  grc "modeIndicator" to (item 1 of tLabelLoc, item 2 of tLabelLoc+12) 
   put "Search" into fld "title-label"
   set the textsize of fld "title-label" to 18
   # have nav bar
   hide button "share"
   hide button "add-favorites" 
   break
end switch   
end preopencard


command __UXHandlers
end __UXHandlers

command startPlayer  pURL, pTitle
   local tRect
   --  local sSelectedURL, tRect
   
   if isMobile() then
      if the platform is "android" then
         # the player is pretty ugly and covers up 120 vertical px
         # we need to try to get it to fit nicely at the bottom:
         put 70,625,350,659 into tRect    #90,630,340,675
      else
         put empty into tRect
      end if
      --breakpoint
      createMobileAudioPlayer pURL, "audioPlayer",tRect
   else
      set the filename of player "audioPlayer" to pURL
   end if
   
   
   # 2019-100-23 BR we are not showing controller  because of iOS 13.0.3
   # instead we are using the icons of grp "pause-pay"
   
   --showPlayer "true", "audioPlayer"
   
   if not isMobile() then
      if sTimeStamp is empty then
         put 0 into sTimeStamp
      end if
      --set the currenttime player "audioPlayer" to sTimeStamp
      start player "audioPlayer"
      get runningAudioIndicatorVis("true")
      --   else
      --      setMobileAudioPlayer "audioPlayer", "play"
   end if
   put  pTitle into fld "currentTitleLabel"
   # Android player covers it! Because the controller higher that iOS one.
   --if the platform is "Android" then
   --set the bottom of fld "currentTitleLabel" to 600
   --end if
   if there is a control "DownloadSelection" then
      set the vis of widget "DownloadSelection" to not sSelectedItemA["cached"]
   end if
   togglePause true, true
end startPlayer

on stopPlayer
   if not isMobile() then
      stop player "audioPlayer"
      set the filename of player "audioPlayer"  to empty
   else 
      setMobileAudioPlayer "audioPlayer", false
      deleteMobileControl "audioPlayer"
   end if
end stopPlayer


on pausePlayer sTimeStamp
   if not isMobile() then
      set the paused of  player "audioPlayer" to "true"
   else  
      setMobileAudioPlayer "audioPlayer", "pause",sTimeStamp
   end if
   togglePause true, false
end pausePlayer


on playPausedAudio sTimeStamp
   if not isMobile() then
      set the currenttime  of player "audioPlayer" to sTimeStamp
      start player "audioPlayer"
   else
      setMobileAudioPlayer "audioPlayer", "play", sTimeStamp
   end if
   togglePause true, true
end playPausedAudio



on clearPlayer
   showPlayer false, "audioPlayer"
   put empty into fld "currentTitleLabel" 
end clearPlayer

command offLineGoMyAudio
   
   local pFolder, tList
   if not connectivity_PingServer() then
      put (path_Documents() & "media/audio") into pFolder
      put listFilesWithPaths(pFolder, "true")  into tList
      if tList is empty then
         dialog_CustomMsg "You have not downloaded any offline audio yet. Network required."
         exit to top
      else
         dialog_CustomMsg "Connection Required. You Can Play Off Line. Going to My Audio"
         go to card "listen-my-audio" 
      end if
      exit to top
   end if
end offLineGoMyAudio

on closeStack
   portal_SetLastStack "Listen"
end closeStack
